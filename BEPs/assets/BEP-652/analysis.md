# BEP-652 Empirical Report

*The following represents a summary with empirical findings from analyzing a `2**24` (16,777,216) transaction gas limit cap.*
*Date: January 28, 2026*

## Dataset

- **Period**: 2025-12-27 to 2026-01-28
- **Blocks analyzed**: 4,802,727
- **Total transactions**: 517,359,109

## Impact Metrics

### Transaction Impact

| Metric | Value |
|--------|-------|
| Affected transactions | 41,604 |
| Impact rate | 0.0080% |
| Unique affected addresses | 5,905 |
| Avg transactions per affected address | 7.0 |

## Gas Analysis (of Affected)

| Metric | Value |
|--------|-------|
| Average gas limit (affected txs) | 30,112,436 |
| Average gas used | 21,864,045 |
| Gas efficiency | 72.6% |
| Min gas used | 10,003,266 |
| Max gas used | 95,975,271 |
| Transactions with unnecessary high limits | 16,254 (39.07%) |

> Note: "Unnecessary high limits" = gasLimit > gasUsed * 1.5 (50% buffer)

## Gas Limit Distribution (gasLimit >= 16,777,216)

| Gas Limit Range | Percentage | Transaction Count |
|-----------------|------------|-------------------|
| 16,777,216 - 30,000,000 | 58.08% | 24,154 |
| 30,000,000 - 40,000,000 | 23.62% | 9,829 |
| >40,000,000 | 18.32% | 7,620 |


## Gas Limit Distribution of Slow Transactions (>500ms)

| Gas Limit Range | Percentage | Transaction Count |
|-----------------|------------|-------------------|
| <= 16,777,216 | 4.21% | 4 |
| 16,777,216 - 30,000,000 | 11.58% | 11 |
| 30,000,000 - 40,000,000 | 16.84% | 16 |
| > 40,000,000 | 67.37% | 64 |

Total slow transactions (>500ms): 95

## Address Analysis

### Top 10 From Addresses

| Rank | Address | Transactions | Avg Gas Limit | Max Gas Limit |
|------|---------|--------------|---------------|---------------|
| 1 | 0x4688e0...ab20 | 4,749 | 24,894,947 | 24,956,279 |
| 2 | 0x5e6d93...9ac5 | 3,394 | 30,945,200 | 30,945,200 |
| 3 | 0xd81904...7220 | 2,808 | 40,945,200 | 40,945,200 |
| 4 | 0x6ad7b5...f848 | 1,634 | 25,191,664 | 61,421,290 |
| 5 | 0xeda91b...9118 | 1,158 | 17,230,949 | 17,314,203 |
| 6 | 0x8c38ce...95ea | 918 | 40,000,000 | 40,000,000 |
| 7 | 0x6205d0...f047 | 767 | 31,493,975 | 53,098,753 |
| 8 | 0x99187c...5889 | 644 | 20,000,000 | 20,000,000 |
| 9 | 0xb433b8...4ea6 | 540 | 23,572,658 | 29,066,877 |
| 10 | 0xc64bf1...7c8e | 481 | 17,351,652 | 17,351,993 |

### Top 10 To Addresses

| Rank | Address | Transactions | % of Total | Note |
|------|---------|--------------|------------|------|
| 1 | 0xba49fa...49dc | 4,749 | 11.4% | Airdrop Contract |
| 2 | 0xffb667...9649 | 3,394 | 8.2% | Batch Transfer Contract |
| 3 | 0xe39a5e...3d26 | 2,525 | 6.1% | Complex Transaction Contract (MEV/Arbitrage) |
| 4 | 0x7d6b49...8d95 | 2,148 | 5.2% | NFT2 Token Contract + Transfer |
| 5 | 0x4d1cdb...dbde | 1,781 | 4.3% | |
| 6 | 0x8ac784...146a | 1,717 | 4.1% | |
| 7 | 0x291c36...bd8c | 1,183 | 2.8% | |
| 8 | 0xe4f072...0e5f | 1,158 | 2.8% | |
| 9 | 0x24293c...4595 | 1,022 | 2.5% | |
| 10 | 0x07964f...0000 | 772 | 1.9% | |

## Migration Analysis

### Transaction Splitting Requirements

If gasLimit capped at 16,777,216, how many splits needed per address:

| Splits Required | Address Count | Percentage |
|-----------------|---------------|------------|
| 2 | 4,295 | 72.7% |
| 3 | 1,218 | 20.6% |
| 4+ | 392 | 6.6% |

Total addresses needing splits: 5,905

## Summary

| Metric | Value |
|--------|-------|
| Affected transactions | 41,604 (0.0080%) |
| Affected addresses | 5,905 |
| Total extra BNB | 0.0084 BNB (at 0.05 gwei) |
| Average splits required | 2.36 |

____
