# Architecture Overview -- Based Angel

## 1. System Philosophy

Based Angel is designed as a hybrid social-financial coordination
system.

Core principles:

-   Deterministic decision-making (no opaque AI logic)
-   On-chain enforcement of all financial constraints
-   Off-chain computation for reputation scoring
-   Radical transparency via public dashboards and logs
-   Minimal trust assumptions

------------------------------------------------------------------------

## 2. High-Level Architecture

User (Base App / XMTP) ↓ Bot Service (TypeScript Runtime) ↓ Reputation
Engine (Deterministic Formula) ↓ BasedAngelVault.sol (On-chain
Enforcement) ↓ AngelSparkNFT.sol (Soulbound Reputation Badge)

------------------------------------------------------------------------

## 3. Components Breakdown

### 3.1 XMTP Listener

Responsible for: - Listening for payment request messages - Parsing
requested token and amount - Validating message structure

No financial execution occurs here.

------------------------------------------------------------------------

### 3.2 Reputation Engine

Location: bot-service/src/reputation.ts

Function: - Fetch Farcaster score (via Neynar) - Fetch Talent Protocol
builder score - Check Basename ownership - Normalize values to 0--1
range - Compute:

R = (0.3 × Farcaster) + (0.5 × Talent) + (0.2 × Basename)

If R ≥ 0.7 → Eligible If R \< 0.7 → Rejected

All inputs and outputs are logged.

------------------------------------------------------------------------

### 3.3 Vault Client

Location: bot-service/src/vaultClient.ts

Responsible for: - Calling disburse() on BasedAngelVault - Handling
transaction confirmation - Updating local logs

The contract enforces: - Per-request cap - 30-day cooldown - Daily
global cap - Token whitelist

------------------------------------------------------------------------

### 3.4 AngelSpark NFT Client

Location: bot-service/src/badgeClient.ts

Responsible for: - Minting NFT on first approval - Calling evolve() if
recipient donates later

NFT is non-transferable.

------------------------------------------------------------------------

## 4. Smart Contract Design

### 4.1 BasedAngelVault.sol

Roles: - OWNER → Multisig - OPERATOR → Bot wallet

Key State: - lastRequestTime\[address\] - totalReceived\[address\] -
dailySpent - lastReset

Hard Constraints: - MAX_PER_REQUEST - USER_COOLDOWN (30 days) -
DAILY_GLOBAL_CAP

No reputation logic exists on-chain.

------------------------------------------------------------------------

### 4.2 AngelSparkNFT.sol

-   ERC-721
-   Transfers disabled
-   Metadata evolves based on donation behavior

------------------------------------------------------------------------

## 5. Transparency Layer

The Next.js dashboard reads:

-   Contract state
-   Event logs
-   Reputation score logs

Displayed publicly: - Vault balance - Total distributed -
Approved/rejected requests - Donor leaderboard - Score breakdowns

------------------------------------------------------------------------

## 6. Evolution Path

Phase 1: - Single scoring provider (hardcoded weights)

Phase 2: - Endorsement modifier

Phase 3: - Modular ScoreProvider interface - SDK release - Governance
integration

------------------------------------------------------------------------

This architecture ensures that financial risk is bounded by smart
contracts, while experimentation occurs safely at the application layer.
