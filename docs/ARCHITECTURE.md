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

User (Base App / XMTP) ↓ OpenClaw Orchestrator (SOUL.md) ↓ Reputation Engine (Deterministic Skill) ↓ BasedAngelVault.sol (On-chain Enforcement) ↓ AngelSparkNFT.sol (Soulbound Reputation Badge)

------------------------------------------------------------------------

## 3. Components Breakdown

### 3.1 OpenClaw Orchestrator

*   **Cognitive Core:** Uses `SOUL.md` to define the "Based Angel" personality and rules of engagement.
*   **Episodic Memory:** Maintains `MEMORY.md` to track past interactions with users, preventing repetitive begging and allowing for "character" growth.
*   **Input Handling:** Receives native XMTP "Payment Requests" as external pokes, which the LLM interprets before deciding to trigger a skill.

------------------------------------------------------------------------

### 3.2 Reputation Engine
*   **Location:** `bot-service/src/skills/reputation.ts`
*   **Function:** This is a deterministic skill. OpenClaw passes the requester's address to this skill, which calculates the score ($R$) using the fixed formula.
*   **Guardrail:** The LLM cannot "hallucinate" an approval; it must receive a success flag from this skill to proceed to the Vault Client.

------------------------------------------------------------------------

### 3.3 Vault Client

### 3.3 Vault & NFT Clients (Action Skills)
*   **Location:** `bot-service/src/skills/vault_ops.ts` and `badge_ops.ts`
*   **Integration:** These skills use CDP AgentKit to sign and broadcast transactions once OpenClaw has confirmed the reputation score meets the threshold ($R \ge 0.7$).

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

## 7 Cognitive Guardrails

*   **Sandbox Execution:** The OpenClaw runtime is isolated to prevent unauthorized system access.

*   **Deterministic Overrides:** Financial execution (disbursing funds) is locked behind the Reputation Skill. The agent cannot bypass the $R \ge 0.7$ check through prompt injection.
*   **Spending Caps:** Smart contract constraints (DAILY_GLOBAL_CAP) act as the final defense if the agent's logic is compromised.


------------------------------------------------------------------------

This architecture ensures that financial risk is bounded by smart
contracts, while experimentation occurs safely at the application layer.
