pragma solidity 0.8.16;

interface IStaking {

  function delegate(address validator, uint256 amount) external payable;

  function undelegate(address validator, uint256 amount) external payable;

  function redelegate(address validatorSrc, address validatorDst, uint256 amount) external payable;

  function claimReward() external returns(uint256);

  function claimUndeldegated() external returns(uint256);

  function getDelegated(address delegator, address validator) external view returns(uint256);

  function getDistributedReward(address delegator) external view returns(uint256);

  function getUndelegated(address delegator) external view returns(uint256);

  function getPendingUndelegateTime(address delegator, address validator) external view returns(uint256);

  function getPendingRedelegateTime(address delegator, address valSrc, address valDst) external view returns(uint256);

  function getOracleRelayerFee() external view returns(uint256);

  function getMinDelegation() external view returns(uint256);
}

contract StakingDappExample {
  bool internal locked;

  // constants
  uint256 public constant TEN_DECIMALS = 10;
  address public constant STAKING_CONTRACT_ADDR = 0x0000000000000000000000000000000000002001;

  // data struct
  struct PoolInfo {
    uint256 rewardPerShare;
    uint256 lastRewardBlock;
    uint256 lastTotalReward;
  }

  struct UserInfo {
    uint256 amount;
    uint256 rewardDebt;
    uint256 pendingUndelegated;
    uint256 undelegateUnlockTime;
  }

  // global variables
  address public owner;
  uint256 public totalReceived;
  uint256 public totalStaked;
  uint256 public totalReward;
  uint256 public reserveReward;
  uint256 public reserveUndelegated;

  PoolInfo internal poolInfo;
  mapping(address => UserInfo) internal userInfo;
  mapping(address => bool) internal operators;

  // modifiers
  modifier onlyOwner() {
    require(msg.sender == owner, "only owner can call this function");
    _;
  }

  modifier onlyOperator() {
    require(operators[msg.sender], "only operator can call this function");
    _;
  }

  modifier noReentrant() {
    require(!locked, "No re-entrancy");
    locked = true;
    _;
    locked = false;
  }

  // events
  event Delegate(address indexed delegator, uint256 amount);
  event DelegateSubmitted(address indexed validator, uint256 amount);
  event Undelegate(address indexed delegator, uint256 amount);
  event UndelegateSubmitted(address indexed validator, uint256 amount);
  event RewardClaimed(address indexed delegator, uint256 amount);
  event UndelegatedClaimed(address indexed delegator, uint256 amount);
  event RewardReceived(uint256 amount);
  event UndelegatedReceived(uint256 amount);

  receive() external payable {}

  constructor() {
    owner = msg.sender;
    operators[msg.sender] = true;
  }

  /*********************** For user **************************/
  // This function will not always submit delegation request to the staking system contract.
  // The delegation will be triggered when unstaked fund is greater than the minDelegationChange.
  function delegate() external payable {
    uint256 amount = msg.value;

    // update reward first
    UserInfo storage user = userInfo[msg.sender];
    _updatePool();
    uint256 pendingReward;
    if (user.amount > 0) {
      pendingReward = user.amount*poolInfo.rewardPerShare-user.rewardDebt;
    }
    user.amount = user.amount+amount;
    user.rewardDebt = user.amount*poolInfo.rewardPerShare-pendingReward;

    totalReceived = totalReceived+amount;
    reserveUndelegated = reserveUndelegated+amount;
    uint256 minDelegation = IStaking(STAKING_CONTRACT_ADDR).getMinDelegation();
    if (reserveUndelegated >= 2*minDelegation) {
      uint256 realAmount = reserveUndelegated-minDelegation;
      uint256 oracleRelayerFee = IStaking(STAKING_CONTRACT_ADDR).getOracleRelayerFee();
      if (address(this).balance < realAmount+oracleRelayerFee) {
        return;
      }
      realAmount = _delegate(realAmount, oracleRelayerFee);
      totalStaked = totalStaked+realAmount;
      reserveUndelegated = reserveUndelegated-realAmount;
    }

    emit Delegate(msg.sender, amount);
  }

  // This function will not always submit delegation request to the staking system contract.
  // The delegation will be triggered when reserve fund is less than the threshold.
  function undelegate(uint256 amount) external {
    UserInfo storage user = userInfo[msg.sender];
    require(user.amount >= amount, "insufficient balance");

    // update reward first
    _updatePool();
    uint256 pendingReward = user.amount*poolInfo.rewardPerShare-user.rewardDebt;
    user.amount  = user.amount-amount;
    user.rewardDebt = user.amount*poolInfo.rewardPerShare-pendingReward;

    user.pendingUndelegated = user.pendingUndelegated+amount;
    user.undelegateUnlockTime = block.timestamp+8*24*3600;

    uint256 minDelegation = IStaking(STAKING_CONTRACT_ADDR).getMinDelegation();
    if (reserveUndelegated < minDelegation) {
      uint256 oracleRelayerFee = IStaking(STAKING_CONTRACT_ADDR).getOracleRelayerFee();
      _undelegate(minDelegation, oracleRelayerFee);
      totalStaked = totalStaked-minDelegation;
      reserveUndelegated = reserveUndelegated+minDelegation;
    }

    totalReceived = totalReceived-amount;
    emit Undelegate(msg.sender, amount);
  }

  function getDelegated(address delegator) external view returns(uint256) {
    return userInfo[delegator].amount;
  }

  function claimReward() external noReentrant {
    UserInfo storage user = userInfo[msg.sender];
    require(user.amount > 0, "no delegation");

    _updatePool();
    uint256 pendingReward = user.amount*poolInfo.rewardPerShare-user.rewardDebt;
    if (reserveReward < pendingReward) {
      _claimReward();
    }
    user.rewardDebt = user.amount*poolInfo.rewardPerShare;
    payable(msg.sender).transfer(pendingReward);
    emit RewardClaimed(msg.sender, pendingReward);
  }

  function claimUndelegated() external noReentrant {
    UserInfo storage user = userInfo[msg.sender];
    require((user.pendingUndelegated > 0) && (block.timestamp > user.undelegateUnlockTime), "no undelegated funds");

    if (reserveUndelegated < user.pendingUndelegated) {
      _claimUndelegated();
    }
    reserveUndelegated = reserveUndelegated-user.pendingUndelegated;
    totalReceived = totalReceived-user.pendingUndelegated;
    user.pendingUndelegated = 0;
    payable(msg.sender).transfer(user.pendingUndelegated);
    emit UndelegatedClaimed(msg.sender, user.pendingUndelegated);
  }

  function getPendingReward(address delegator) external view returns(uint256 pendingReward) {
    UserInfo memory user = userInfo[delegator];
    pendingReward = user.amount*poolInfo.rewardPerShare-user.rewardDebt;
  }

  /************************** Internal **************************/
  function _getHighestYieldingValidator() internal pure returns(uint160 highestYieldingValidator) {
    // this function should return the desirable validator to delegate to
    // need to be implemented by the developer
    // use uint160 rather than address to prevent checksum error
    highestYieldingValidator = uint160(0x001);
  }

  function _getLowestYieldingValidator() internal pure returns(uint160 lowestYieldingValidator) {
    // this function should return the desirable validator to undelegate from
    // need to be implemented by the developer
    // use uint160 rather than address to prevent checksum error
    lowestYieldingValidator = uint160(0x002);
  }

  function _delegate(uint256 amount, uint256 oracleRelayerFee) internal returns(uint256) {
    address validator = address(_getHighestYieldingValidator());
    amount -= amount%TEN_DECIMALS;
    IStaking(STAKING_CONTRACT_ADDR).delegate{value: amount+oracleRelayerFee}(validator, amount);
    emit DelegateSubmitted(validator, amount);
    return amount;
  }

  function _undelegate(uint256 amount, uint256 oracleRelayerFee) internal returns(uint256) {
    address validator = address(_getLowestYieldingValidator());
    amount -= amount%TEN_DECIMALS;
    IStaking(STAKING_CONTRACT_ADDR).undelegate{value: oracleRelayerFee}(validator, amount);
    emit UndelegateSubmitted(validator, amount);
    return amount;
  }

  function _claimReward() internal {
    uint256 amount = IStaking(STAKING_CONTRACT_ADDR).claimReward();
    totalReward = totalReward+amount;
    reserveReward = reserveReward+amount;
    emit RewardReceived(amount);
  }

  function _claimUndelegated() internal {
    uint256 amount = IStaking(STAKING_CONTRACT_ADDR).claimUndeldegated();
    emit UndelegatedReceived(amount);
  }

  function _updatePool() internal {
    if (block.number <= poolInfo.lastRewardBlock) {
      return;
    }
    if (totalReward == poolInfo.lastTotalReward) {
      return;
    }
    uint256 newReward = totalReward - poolInfo.lastTotalReward;
    poolInfo.lastTotalReward = totalReward;
    poolInfo.rewardPerShare = poolInfo.rewardPerShare+newReward/totalStaked;
    poolInfo.lastRewardBlock = block.number;
  }

  /*********************** Handle faliure **************************/
  // This parts of functions should be called by the operator when failed event detected by the monitor
  function handleFailedDelegate(uint256 amount) external onlyOperator {
    totalStaked = totalStaked-amount;
    reserveUndelegated = reserveUndelegated+amount;

    amount = IStaking(STAKING_CONTRACT_ADDR).claimUndeldegated();
    uint256 oracleRelayerFee = IStaking(STAKING_CONTRACT_ADDR).getOracleRelayerFee();
    require(address(this).balance > amount+oracleRelayerFee, "insufficient balance");
    amount = _delegate(amount, oracleRelayerFee);
    totalStaked = totalStaked+amount;
    reserveUndelegated = reserveUndelegated-amount;
  }

  function handleFailedUndelegate(uint256 amount) external onlyOperator {
    totalStaked = totalStaked+amount;
    reserveUndelegated = reserveUndelegated-amount;

    uint256 oracleRelayerFee = IStaking(STAKING_CONTRACT_ADDR).getOracleRelayerFee();
    require(address(this).balance > oracleRelayerFee, "insufficient balance");
    amount = _undelegate(amount, oracleRelayerFee);
    totalStaked = totalStaked-amount;
    reserveUndelegated = reserveUndelegated+amount;
  }

  /*********************** Params update **************************/
  function transferOwnership(address newOwner) external onlyOwner {
    owner = newOwner;
  }

  function addOperator(address opt) external onlyOwner {
    operators[opt] = true;
  }

  function delOperator(address opt) external onlyOwner {
    operators[opt] = false;
  }
}
