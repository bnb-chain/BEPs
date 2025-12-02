# BEP-620 相对于 ERC-8004 的 BNB Chain 特定修改

## 概述

BEP-620 将 ERC-8004 Trustless Agents 标准引入 BNB Chain 生态，在保持完整接口兼容性的同时，针对 BNB Chain 的技术优势和生态特点进行了本地化适配。

---

## 核心修改点

### 1. 突出 BSC 的性能优势

**原文（ERC-8004）**:
> To foster an open, cross-organizational agent economy, we need mechanisms for discovering and trusting agents in untrusted settings.

**修改后（BEP-620）**:
> BNB Smart Chain, with its low gas fees (~$0.001 per transaction) and high throughput (~2000 TPS), provides an ideal foundation for frequent agent interactions and reputation updates that would be cost-prohibitive on other networks.

**修改理由**: 明确 BSC 的低 Gas 费用和高吞吐量优势，强调这是 Agent 经济的理想基础设施。

---

### 2. 引入 opBNB L2 支持

**新增内容**:
> This BEP addresses this need through three lightweight registries deployed on BSC (and optionally on opBNB for even lower costs)

> For applications requiring even lower costs, opBNB provides an L2 alternative with sub-cent transaction fees.

**修改理由**: opBNB 作为 BNB Chain 的 L2 解决方案，为高频 Agent 交互提供更低成本的选择。

---

### 3. 集成 BNB Greenfield 存储

**原文（ERC-8004）**:
> Since feedback data is saved on-chain and we suggest using IPFS for full data...

**修改后（BEP-620）**:
> Since feedback data is saved on-chain and we suggest using IPFS or BNB Greenfield for full data storage, it's easy to leverage subgraphs to create indexers and improve UX. BNB Greenfield offers a native decentralized storage solution within the BNB Chain ecosystem.

**修改理由**: BNB Greenfield 是 BNB Chain 生态的原生去中心化存储解决方案，为 Agent 数据存储提供更紧密的生态集成。

---

### 4. 强调跨链兼容性

**新增内容**:
> **Cross-Chain Compatibility**: This standard maintains full compatibility with ERC-8004 deployments on other EVM chains, enabling agents to build reputation across the multi-chain ecosystem.

> This standard is fully compatible with ERC-8004 on Ethereum and other EVM chains, allowing agents to maintain interoperable identities and reputation across the multi-chain ecosystem.

**修改理由**: 明确 BEP-620 与 ERC-8004 的互操作性，Agent 可以在多链生态中构建统一的声誉。

---

### 5. BSC 链 ID 适配

**示例中的修改**:
- `chainId`: 使用 `56`（BSC Mainnet）替代 Ethereum 的 `1`
- `agentWallet` endpoint: `eip155:56:0x...`
- `agentRegistry`: `eip155:56:{identityRegistry}`

---

## 保持不变的内容

以下内容与 ERC-8004 完全一致，确保标准兼容性：

| 内容 | 说明 |
|------|------|
| Solidity 接口定义 | 所有函数签名、事件、结构体完全兼容 |
| JSON Schema | `type` 字段保持 ERC-8004 的 URL 引用 |
| 签名标准 | 继续使用 EIP-191 / ERC-1271 |
| Trust Models | 三种信任模型（reputation、crypto-economic、tee-attestation）不变 |
| Security Considerations | 安全考虑完全保留 |

---

## 宣发要点

### 中文版

1. **首个 AI Agent 信任基础设施标准落地 BNB Chain** - BEP-620 为 BNB Chain 生态引入标准化的 Agent 发现和信任机制

2. **低成本 Agent 经济** - 借助 BSC 的低 Gas（~$0.001/交易）和 opBNB 的亚美分交易费用，让高频 Agent 交互成为可能

3. **BNB Chain 生态深度集成** - 原生支持 BNB Greenfield 去中心化存储，无缝对接 BSC 和 opBNB

4. **跨链互操作** - 与 ERC-8004 完全兼容，Agent 可在多链生态中构建统一声誉

### English Version

1. **First AI Agent Trust Infrastructure on BNB Chain** - BEP-620 brings standardized agent discovery and trust mechanisms to the BNB Chain ecosystem

2. **Low-Cost Agent Economy** - BSC's low gas (~$0.001/tx) and opBNB's sub-cent fees enable high-frequency agent interactions

3. **Deep BNB Chain Integration** - Native support for BNB Greenfield storage, seamless BSC and opBNB deployment

4. **Cross-Chain Interoperability** - Fully compatible with ERC-8004, enabling agents to build unified reputation across multi-chain ecosystems

---

## 参考链接

- ERC-8004 原始标准: https://eips.ethereum.org/EIPS/eip-8004
- 参考实现: https://github.com/erc-8004/erc-8004-contracts
- BNB Greenfield: https://greenfield.bnbchain.org
- opBNB: https://opbnb.bnbchain.org
