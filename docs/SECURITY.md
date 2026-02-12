# Security Model -- Based Angel

## 1. Threat Model

The system must defend against:

-   Sybil attacks
-   Reputation gaming
-   Vault draining
-   Operator key compromise
-   Developer rug concerns
-   Social manipulation
-   API dependency failure

------------------------------------------------------------------------

## 2. On-Chain Security

### 2.1 Role Separation

-   OWNER → 2-of-3 Multisig
-   OPERATOR → Bot wallet
-   No single key controls funds

------------------------------------------------------------------------

### 2.2 Spending Caps

Hardcoded constraints:

-   Max per request (e.g., 0.002 ETH)
-   30-day per-user cooldown
-   Daily global cap (e.g., 0.1 ETH)

Even if the bot is compromised, maximum damage is bounded.

------------------------------------------------------------------------

### 2.3 No Arbitrary Withdrawals

The contract does not include unrestricted withdraw functions. Owner
actions are limited and transparent.

------------------------------------------------------------------------

## 3. Off-Chain Security

### 3.1 Deterministic Scoring

No LLM-based approval logic. Score formula is public and fixed.

------------------------------------------------------------------------

### 3.2 Public Score Logs

Each request logs: - Raw Farcaster score - Raw Talent score - Basename
bonus - Final R value - Approval or rejection

Transparency reduces manipulation claims.

------------------------------------------------------------------------

## 4. Sybil Resistance

Signals used:

-   Farcaster activity score
-   Talent Protocol builder score
-   Basename ownership

Future Enhancements:

-   GitHub contribution analysis
-   WorldID integration
-   On-chain activity scoring

------------------------------------------------------------------------

## 5. API Dependency Risk

Neynar and Talent Protocol APIs are external dependencies.

Mitigations:

-   Caching responses
-   Fallback rejection if APIs fail
-   Versioned score normalization

------------------------------------------------------------------------

## 6. Vault Drain Mitigation

Worst-case scenarios:

1.  Coordinated high-reputation abuse
2.  Operator key compromise

Impact is limited due to: - Per-user cooldown - Daily global cap -
Public dashboard visibility

------------------------------------------------------------------------

## 7. Agentic Risk Mitigation:

Worst-case scenarios:

1.  **Prompt Injection Protection:** Even if a user tricks the OpenClaw LLM into wanting to send money, the AgentKit Skill independently verifies the Reputation Score ($R$) before signing the transaction.
2.  **Sandboxed Execution:** The OpenClaw runtime is isolated, ensuring that a compromised agent cannot access the host machine's root files.

Impact is limited due to: - Per-user cooldown - Daily global cap -
Public dashboard visibility

------------------------------------------------------------------------

## 7. Transparency as Defense

Public visibility includes:

-   Vault balance
-   Daily spend
-   Transaction history
-   Score breakdowns

Open-source contracts are verified on BaseScan.

------------------------------------------------------------------------

## 8. Long-Term Security Roadmap

Phase 2: - Add community endorsement modifier - Introduce anomaly
detection

Phase 3: - Modular ScoreProvider contracts - Governance-controlled
parameter updates - Formal audit

------------------------------------------------------------------------

Based Angel is designed so that no single component failure can cause
catastrophic fund loss.
