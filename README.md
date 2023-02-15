# BEPs

BEP stands for BNB Evolution Proposal. Each BEP will be a proposal document providing information to the BNB Chain ecosystem and community.


Here is the list of subjects of BEPs:

| Number               | Title                                                      | Type      | Status  |
| -------------------- | ---------------------------------------------------------- | --------- | ------- |
| [BEP-1](BEP1.md)     | Purpose and Guidelines of BEP                              | Process   | Living  |
| [BEP-2](BEP2.md)     | Tokens on BNB Beacon Chain                                 | Standards | Enabled |
| [BEP-3](BEP3.md)     | HTLC and Atomic Peg                                        | Standards | Enabled |
| [BEP-6](BEP6.md)     | Delist Trading Pairs on BNB Beacon Chain                   | Standards | Enabled |
| [BEP-8](BEP8.md)     | Mini-BEP2 Tokens                                           | Standards | Enabled |
| [BEP-9](BEP9.md)     | Time Locking of Tokens on BNB Beacon Chain                 | Standards | Enabled |
| [BEP-10](BEP10.md)   | Registered Types for Transaction Source                    | Standards | Enabled |
| [BEP-12](BEP12.md)   | Introduce Customized Scripts and Transfer Memo Validation  | Standards | Enabled |
| [BEP-18](BEP18.md)   | State sync enhancement                                     | Standards | Enabled |
| [BEP-19](BEP19.md)   | Introduce Maker and Taker for Match Engine                 | Standards | Enabled |
| [BEP-20](BEP20.md)   | Tokens on BNB Smart Chain                                  | Standards | Enabled |
| [BEP-67](BEP67.md)   | Price-based Order                                          | Standards | Enabled |
| [BEP-70](BEP70.md)   | List and Trade BUSD Pairs                                  | Standards | Enabled |
| [BEP-82](BEP82.md)   | Token Ownership Changes                                    | Standards | Enabled |
| [BEP-84](BEP84.md)   | Mirror BEP20 to BNB Beacon Chain                           | Standards | Enabled |
| [BEP-86](BEP86.md)   | Dynamic Extra Incentive For BSC Relayers                   | Standards | Enabled |
| [BEP-87](BEP87.md)   | Token Symbol Minimum Length Change                         | Standards | Enabled |
| [BEP-89](BEP89.md)   | Visual Fork of BNB Smart Chain                             | Standards | Enabled |
| [BEP-91](BEP91.md)   | Increase Block Gas Ceiling for BNB Smart Chain             | Standards | Enabled |
| [BEP-93](BEP93.md)   | Diff Sync Protocol on BSC                                  | Standards | Enabled |
| [BEP-95](BEP95.md)   | Introduce Real-Time Burning Mechanism                      | Standards | Enabled |
| [BEP-127](BEP127.md) | Temporary Maintenance Mode for Validators                  | Standards | Enabled |
| [BEP-128](BEP128.md) | Improvement on BNB Smart Chain Staking Reward Distribution | Standards | Enabled |
| [BEP-131](BEP131.md) | Introduce candidate validators onto BNB Smart Chain        | Standards | Enabled |
| [BEP-151](BEP151.md) | Decommission Decentralized Exchange on BNB Beacon Chain    | Standards | Enabled |
| [BEP-153](BEP153.md) | Introduce native staking onto BNB Smart Chain              | Standards | Enabled |
| [BEP-159](BEP159.md) | Introduce A New Staking Mechanism on BNB Beacon Chain      | Standards | Draft   |
| [BEP-173](BEP173.md) | Introduce Text Governance Proposal for BNB Smart Chain     | Standards | Enabled |

# BNB Smart Chain Upgrades
Note: the upcoming Bohr upgrade is expected to be enabled on mainnet at the end of Mar 2023
| Upgrade    | Changes                                                                                                                                                                                                                                                                                                                                                    | Mainnet Height | Testnet Height |
| ---------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------------: | :------------: |
| Bohr       | [BEP-171: Security Enhancement for Cross-Chain Module](https://github.com/bnb-chain/BEPs/pull/171) <br />[BEP-172: Network Stability Enhancement On Slash Occur](https://github.com/bnb-chain/BEPs/pull/172)<br />[BEP-188: Early Broadcast Mature Block For In-Turn Validators](https://github.com/bnb-chain/BEPs/pull/188)                               |      TBD       |      TBD       |
| Gibbs      | [BEP-153: Introduce Native Staking on BSC](BEP153.md)                                                                                                                                                                                                                                                                                                      |    23846001    |    22800220    |
| Moran      | Fix the exploiter attack                                                                                                                                                                                                                                                                                                                                   |    22107423    |    23603940    |
| Nano       | Suspend CrossChain between BC & BSC due to the exploiter attack                                                                                                                                                                                                                                                                                            |    21962149    |    23482428    |
| Euler      | [BEP-127 Temporary Maintenance Mode for Validators](127.md)<br /> [BEP-131 Introduce candidate validators onto BNB Smart Chain](131.md)                                                                                                                                                                                                                    |    18907621    |    19203503    |
| Bruno      | [BEP-95: Real-Time Burning Mechanism ](95.md)<br /> [BEP-93: Diff Sync Protocol: Speed up node sync](93.md)                                                                                                                                                                                                                                                |    13082000    |    13837000    |
| MirrorSync | Upgrade 3 system contracts (no BEP):<br /> - [TokenManagerContract](https://bscscan.com/address/0x0000000000000000000000000000000000001008)<br /> - [TokenHubContract](https://bscscan.com/address/0x0000000000000000000000000000000000001004)<br /> -[RelayerIncentivizeContract](https://bscscan.com/address/0x0000000000000000000000000000000000001005) |    5184000     |    5582500     |



### Bohr(Upcoming)
> Candidate List(Expect to be enabled at the end of Mar 2023)
- [BEP-171: Security Enhancement for Cross-Chain Module](https://github.com/bnb-chain/BEPs/pull/171)
- [BEP-172: Network Stability Enhancement On Slash Occur](https://github.com/bnb-chain/BEPs/pull/172)
- [BEP-188: Early Broadcast Mature Block For In-Turn Validators](https://github.com/bnb-chain/BEPs/pull/188)

### Gibbs
> BSC mainnet enabled on Dec 12th 2022
- [BEP-153: Introduce Native Staking on BSC](BEP153.md)

### Moran
> BSC mainnet enabled on Oct 12th 2022
- Fix the exploiter attack (emergency, no BEP)

### Nano
> BSC mainnet enabled on Oct 6th 2022
- Suspend CrossChain between BC & BSC due to the exploiter attack (emergency, no BEP)

### Euler
> BSC mainnet enabled on Jun 22th 2022
- [BEP-127 Temporary Maintenance Mode for Validators](127.md)
- [BEP-131 Introduce candidate validators onto BNB Smart Chain](131.md)

### Bruno
> BSC mainnet enabled on Nov 30th 2021
- [BEP-95: Real-Time Burning Mechanism ](95.md)
- [BEP-93: Diff Sync Protocol: Speed up node sync](93.md)

### MirrorSync
> BSC mainnet enabled on Feb 25th 2021
- Upgrade 3 system contract (no BEP):
  [TokenManagerContract](https://bscscan.com/address/0x0000000000000000000000000000000000001008), [TokenHubContract](https://bscscan.com/address/0x0000000000000000000000000000000000001004), [RelayerIncentivizeContract](https://bscscan.com/address/0x0000000000000000000000000000000000001005)


# How To Contribute A BEP
If you have an idea and want to make it a BEP, you may refer [BEP-1](BEP1.md)