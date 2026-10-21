# ALP v0.4-draft conformance matrix

This is a normative acceptance matrix for implementations of [ALP](protocol.md) and [the BSC binding](../../BAP-728.md). It is not a report of passing implementations. [examples.json](examples.json) contains illustrative records for every schema; its proofs and addresses have no deployment validity.

Each implementation MUST publish a reproducible harness, exact module and dependency revisions, network and binding manifests, artifact digest, initial conditions, actions, expected outcomes, and observed evidence. Mocked results MUST be labeled and MUST NOT establish live payment, finality, migration, or chain-deployment conformance. Private credentials MUST be excluded from published evidence.

## Core Agent

| ID | Scenario | Required result |
| --- | --- | --- |
| CORE-01 | Provision with missing approval, implicit cap, or owner wallet substituted for dedicated wallet | Deny PROVISIONED. |
| CORE-02 | Complete registration, wallet proof, publication, and finalized checkpoint | Commit REGISTERED exactly once; read-back wallet equals approved dedicated wallet. |
| CORE-03 | Registry registration succeeds, wallet proof or publication fails, then retry | Remain PROVISIONED until reconciled; reuse original identity; no ordinary signing. |
| CORE-04 | Activation payment simulates successfully, reverts, or remains unfinalized | Deny ACTIVE; hold unresolved liabilities. |
| CORE-05 | Real payment finalizes and provider credit is verified | Commit ACTIVE once; evidence links payment to correct resource account. |
| CORE-06 | Same transition operation retried; same ID used with changed request; competing expected sequence | Return original logical result; reject changed contents and stale contender. |
| CORE-07 | Owner suspension races a new payment and new task | Gates serialize the race; after suspension gate commits, neither action starts. |
| CORE-08 | Attempt RETIRED-to-ACTIVE, new controller, registry metadata overwrite, or ownership transfer | Retirement remains terminal in pinned lifecycle trust domain. |
| CORE-09 | Owner transfer or agentWallet change occurs while ACTIVE | Reject cached sessions/delegations; stop intake and suspend; require new approval. |
| CORE-10 | Retirement leaves pending signatures, allowance, or unresolved job | Stop work; cleanup stays pending until revoked/expired or bounded settlement transferred; no obligation silently erased. |
| PAY-01 | Unlisted beneficiary, wrong asset/chain/method, excessive quote, or stale quote | Signer denies; model output cannot override decision. |
| PAY-02 | Two concurrent requests together exceed rolling cap, including different rails | At most allowed liability reserved; overspend attempt suspends. |
| PAY-03 | Authorization remains executable after 24 hours or after process restart | Liability remains reserved; no cap reset bypass. |
| PAY-04 | Payment finalized; response/credit receipt lost; HTTP retry | Reconcile original authorization/purchase; no duplicate refill. |
| PAY-05 | Proven cancellation, expiry, success, or refund | Reservation released only on proof; success not double-counted; refund does not reset gross cap. |
| PAY-06 | Clock rolls back, accounting unavailable, or payment crosses balance floor | Deny signing and suspend until reconciled. |
| DISC-01 | Valid chain identity, descriptor digest, and fresh wallet handshake | Authenticate exact audience, identity, epoch, and descriptor; no automatic spend grant. |
| DISC-02 | Replay, expired proof, wrong audience/domain/chain, stale epoch, or altered descriptor | Reject every variant. |
| DISC-03 | Directory says ACTIVE but lifecycle record is SUSPENDED or RETIRED | Reject economic session; chain record prevails. |
| BSC-01 | Receipt is reorged before declared finality, or RPC providers disagree | Do not advance lifecycle; reconcile or fail closed. |
| BSC-02 | Upgrade token/registry proxy or change manifest ABI digest | Invalidate cached compatibility; revalidate before operation. |
| SCHEMA-01 | Validate each A.1-A.8 example and reject missing required fields, extra fields, malformed amounts/hashes | Shape validation succeeds only for allowed records; semantic checks are separately exercised. |

## Portable Runtime

| ID | Scenario | Required result |
| --- | --- | --- |
| RT-01 | Migrate with in-flight jobs and rolling-cap reservations | Preserve identity, policy, wallet, commitments, and full accounting across all six phases. |
| RT-02 | Partition source after quiesce; it attempts intake and signing | Shared epoch fencing denies both before target authority is issued. |
| RT-03 | Source issued a still-executable authorization | Target remains without authority until original liability is reconciled/cancelled/expired. |
| RT-04 | Crash at each migration phase, repeat operation, or restore old checkpoint | At most one lease; deterministic recovery; old epoch never restored. |
| RT-05 | Import corrupted checkpoint or export containing a raw key | Reject import/export and remain safely suspended. |

## A2A Agent and Certified Toolchain

| ID | Profile and scenario | Required result |
| --- | --- | --- |
| A2A-01 | Validate card against declared A2A version and authenticate lifecycle extension | Valid card, verified coordinates, explicit supported economic capabilities. |
| A2A-02 | Cancel transport task or report transport completion | No automatic escrow refund or settlement claim. |
| VERIFY-01 | Repeat verifier with identical artifact/configuration/rule-pack snapshots | Identical verdict and stable finding identifiers. |
| VERIFY-02 | Embedded key, model-readable secret, unbounded allowance, signer bypass, or unlisted payee fixture | FAIL or INDETERMINATE; Certified Toolchain refuses deployment. |
| VERIFY-03 | Change artifact, security configuration, or rule pack after PASS | Old verdict cannot authorize new deployment. |

## Commerce Agent

| ID | Scenario | Required result |
| --- | --- | --- |
| COMM-01 | Fund, submit, evaluate, and settle using pinned upstream ABI | Preserve ERC-8183 states/roles; release exact committed funds once. |
| COMM-02 | Change terms, fee, asset, evaluator, or arbiter after funding | Reject; original agreement governs. |
| COMM-03 | Deterministic predicate settles the committed criteria | Do not invoke subjective arbiter unnecessarily; record evidence. |
| COMM-04 | Trigger timeout at exact funding/delivery/evaluation/underlying expiry boundary | Anyone can execute precommitted default; late competing action denied. |
| COMM-05 | Third party front-runs dispute request, alters evidence, or injects wrong/late/duplicate ruling | Authenticate adapter and tuple; reject conflicting requests; ignore late ruling; no double payout. |
| COMM-06 | Arbiter unavailable, evaluator adapter fails, or provider retires | Timeout and native expiry refund remain reachable; retirement does not rewrite terms. |
| COMM-07 | Cancel unfunded adapter agreement while underlying job remains Open | Further funding of that agreement is impossible. |
| COMM-08 | Fee-on-transfer/rebasing token without accounting support | Reject before funding. |

## Claims and remaining implementation work

A conformance claim MUST list the IDs run and actual outcomes, distinguish live integration from simulation, and name its assessor. Baseline Core Agent tests are required by all agent profiles; optional module tests apply only to claims including those modules. Certified Toolchain must enforce the gate and demonstrate Core provisioning/activation through its output agents.

Before claiming a live BSC profile, implementers must publish the lifecycle registry contract, deployment manifest with verified addresses and dependency pins, policy-enforcing wallet binding, provider/facilitator integration, and reproducible results. Commerce and migration additionally require their tested adapters and fencing service. Schema validation alone meets none of those implementation requirements.

## License

CC0, as in the companion BAP.
