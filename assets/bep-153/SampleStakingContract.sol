pragma solidity 0.6.4;

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

library SafeMath {
  /**
   * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  /**
   * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

  /**
   * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  /**
   * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  /**
   * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract StakingDappExample {
  using SafeMath for uint256;

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

  PoolInfo poolInfo;
  mapping(address => UserInfo) userInfo;
  mapping(address => bool) operators;

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
  event Delegate(address indexed delegator, address indexed validator, uint256 amount);
  event Undelegate(address indexed validator, uint256 amount);
  event ClaimReward(address indexed delegator, uint256 amount);
  event ClaimUndelegated(address indexed delegator, uint256 amount);
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
      pendingReward = user.amount.mul(poolInfo.rewardPerShare).sub(user.rewardDebt);
    }
    user.amount = user.amount.add(amount);
    user.rewardDebt = user.amount.mul(poolInfo.rewardPerShare).sub(pendingReward);

    totalReceived = totalReceived.add(amount);
    reserveUndelegated = reserveUndelegated.add(amount);
    amount = IStaking(STAKING_CONTRACT_ADDR).getMinDelegation();
    if (reserveUndelegated >= 2*amount) {
      uint256 oracleRelayerFee = IStaking(STAKING_CONTRACT_ADDR).getOracleRelayerFee();
      if (address(this).balance < amount.add(oracleRelayerFee)) {
        return;
      }
      _delegate(amount, oracleRelayerFee);
      totalStaked = totalStaked.add(amount);
      reserveUndelegated = reserveUndelegated.sub(amount);
    }
  }

  // This function will not always submit delegation request to the staking system contract.
  // The delegation will be triggered when reserve fund is less than the threshold.
  function undelegate(uint256 amount) external {
    UserInfo storage user = userInfo[msg.sender];
    require(user.amount >= amount, "insufficient balance");

    // update reward first
    _updatePool();
    uint256 pendingReward = user.amount.mul(poolInfo.rewardPerShare).sub(user.rewardDebt);
    user.amount  = user.amount.sub(amount);
    user.rewardDebt = user.amount.mul(poolInfo.rewardPerShare).sub(pendingReward);

    user.pendingUndelegated = user.pendingUndelegated.add(amount);
    user.undelegateUnlockTime = block.timestamp.add(7*24*3600);

    amount = IStaking(STAKING_CONTRACT_ADDR).getMinDelegation();
    if (reserveUndelegated < amount) {
      uint256 oracleRelayerFee = IStaking(STAKING_CONTRACT_ADDR).getOracleRelayerFee();
      _undelegate(amount, oracleRelayerFee);
      totalStaked = totalStaked.sub(amount);
      reserveUndelegated = reserveUndelegated.add(amount);
    }

    totalReceived = totalReceived.sub(amount);
    emit undelegateSubmitted(msg.sender, amount);
  }

  function claimReward() external noReentrant {
    UserInfo storage user = userInfo[msg.sender];
    require(user.amount > 0, "no delegation");

    _updatePool();
    uint256 pendingReward = user.amount.mul(poolInfo.rewardPerShare).sub(user.rewardDebt);
    if (reserveReward < pendingReward) {
      _claimReward();
    }
    payable(msg.sender).transfer(pendingReward);
    user.rewardDebt = user.amount.mul(poolInfo.rewardPerShare);
    emit rewardClaimed(msg.sender, pendingReward);
  }

  function claimUndelegated() external noReentrant {
    UserInfo storage user = userInfo[msg.sender];
    require((user.pendingUndelegated > 0) && (block.timestamp > user.undelegateUnlockTime), "no undelegated funds");

    if (reserveUndelegated < user.pendingUndelegated) {
      _claimUndelegated();
    }
    payable(msg.sender).transfer(user.pendingUndelegated);
    reserveUndelegated = reserveUndelegated.sub(user.pendingUndelegated);
    totalReceived = totalReceived.sub(user.pendingUndelegated);
    user.pendingUndelegated = 0;
    emit undelegatedClaimed(msg.sender, user.pendingUndelegated);
  }

  function getPendingReward() external view returns(uint256 pendingReward) {
    UserInfo storage user = userInfo[msg.sender];
    pendingReward = user.amount.mul(poolInfo.rewardPerShare).sub(user.rewardDebt);
  }

  /************************** Internal **************************/
  function _getHighestYieldingValidator() internal pure returns(address highestYieldingValidator) {
    // this function should return the desirable validator to delegate to
    // need to be implemented by the developer
    highestYieldingValidator = address(0x1);
  }

  function _getLowestYieldingValidator() internal pure returns(address lowestYieldingValidator) {
    // this function should return the desirable validator to undelegate from
    // need to be implemented by the developer
    lowestYieldingValidator = address(0x2);
  }

  function _delegate(uint256 amount, uint256 oracleRelayerFee) internal {
    address validator = _getHighestYieldingValidator();
    IStaking(STAKING_CONTRACT_ADDR).delegate{value: amount.add(oracleRelayerFee)}(validator, amount);
    emit delegateSubmitted(msg.sender, validator, amount);
  }

  function _undelegate(uint256 amount, uint256 oracleRelayerFee) internal {
    address validator = _getLowestYieldingValidator();
    IStaking(STAKING_CONTRACT_ADDR).undelegate{value: oracleRelayerFee}(validator, amount);
    emit undelegateSubmitted(validator, amount);
  }

  function _claimReward() internal {
    uint256 amount = IStaking(STAKING_CONTRACT_ADDR).claimReward();
    totalReward = totalReward.add(amount);
    reserveReward = reserveReward.add(amount);
    emit rewardReceived(amount);
  }

  function _claimUndelegated() internal {
    uint256 amount = IStaking(STAKING_CONTRACT_ADDR).claimUndeldegated();
    emit undelegatedReceived(amount);
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
    poolInfo.rewardPerShare = poolInfo.rewardPerShare.add(newReward.div(totalStaked));
    poolInfo.lastRewardBlock = block.number;
  }

  /*********************** Handle faliure **************************/
  // This parts of functions should be called by the operator when failed event detected by the monitor
  function handleFailedDelegate(uint256 amount) external onlyOperator {
    totalStaked = totalStaked.sub(amount);
    reserveUndelegated = reserveUndelegated.add(amount);

    amount = IStaking(STAKING_CONTRACT_ADDR).claimUndeldegated();
    uint256 oracleRelayerFee = IStaking(STAKING_CONTRACT_ADDR).getOracleRelayerFee();
    require(address(this).balance > amount.add(oracleRelayerFee), "insufficient balance");
    _delegate(amount, oracleRelayerFee);
    totalStaked = totalStaked.add(amount);
    reserveUndelegated = reserveUndelegated.sub(amount);
  }

  function handleFailedUndelegate(uint256 amount) external onlyOperator {
    totalStaked = totalStaked.add(amount);
    reserveUndelegated = reserveUndelegated.sub(amount);

    uint256 oracleRelayerFee = IStaking(STAKING_CONTRACT_ADDR).getOracleRelayerFee();
    require(address(this).balance > oracleRelayerFee, "insufficient balance");
    _undelegate(amount, oracleRelayerFee);
    totalStaked = totalStaked.sub(amount);
    reserveUndelegated = reserveUndelegated.add(amount);
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
