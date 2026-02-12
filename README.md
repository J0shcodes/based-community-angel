# 😇 Based Angel

**A Base-native experiment in programmable, reputation-weighted
micro-disbursement.**

Based Angel is a social-financial coordination experiment built on the
Base network.\
It addresses the *"last-mile gas problem"* by enabling reputation-gated
micro-disbursements funded by the community.

Instead of operating as a simple faucet, Based Angel introduces a
transparent, rule-based system that distributes small amounts of ETH or
stablecoins to users based on measurable on-chain and social reputation
signals.

------------------------------------------------------------------------

## 🌍 Vision

Turn gas assistance from a transactional request into a visible,
reputation-powered social loop.

Long-term, Based Angel evolves into a modular **Reputation Vault
Protocol** --- enabling communities on Base to deploy programmable
micro-grant vaults.

------------------------------------------------------------------------

# 🧱 Architecture Overview

    User (Base App / XMTP)
            ↓
    Angel Bot (TypeScript Service)
            ↓
    Reputation Engine (Deterministic Logic)
            ↓
    BasedAngelVault.sol (Smart Contract)
            ↓
    AngelSparkNFT.sol (Soulbound Reputation Badge)

The smart contract enforces strict rules.\
The bot calculates reputation.\
The dashboard ensures transparency.

------------------------------------------------------------------------

# 🏦 Smart Contracts

## BasedAngelVault.sol

A secure, role-restricted vault contract deployed on Base.

### Key Features

-   Per-request maximum cap (e.g., 0.002 ETH)
-   30-day cooldown per address
-   Daily global spending cap
-   Multi-token support (ETH + USDC initially)
-   Operator role for bot execution
-   Multisig owner control

### Security Model

-   The AI agent is **Operator**, not Owner.
-   Owner is a 2-of-3 multisig.
-   No unrestricted withdrawal functions.
-   All logic enforced on-chain.

------------------------------------------------------------------------

## AngelSparkNFT.sol

A non-transferable (soulbound) ERC-721 reputation badge.

### Features

-   Minted on first approved disbursement
-   Non-transferable
-   Evolves if recipient donates back to the vault
-   Publicly visible reputation signal

------------------------------------------------------------------------

# 🤖 Reputation Engine

Reputation Score Formula:

R = (0.3 × Farcaster Score)\
+ (0.5 × Talent Protocol Score)\
+ (0.2 × Basename Bonus)

Threshold:\
Only users with **R ≥ 0.7** qualify.

All score breakdowns are logged and viewable on the dashboard.

------------------------------------------------------------------------

# 💬 Bot Service

Built using:

-   XMTP Agent SDK
-   Coinbase AgentKit (CDP)
-   TypeScript runtime

Responsibilities: - Listen for payment requests - Calculate reputation
score - Call vault disbursement - Mint or evolve AngelSpark NFT - Log
actions to public ledger

------------------------------------------------------------------------

# 📊 Transparency Dashboard

Built with Next.js.

Displays:

-   Vault balance
-   Total distributed funds
-   Approved vs rejected requests
-   Score breakdown per request
-   Cooldown timers
-   Donor leaderboard
-   AngelSpark holders

The dashboard reduces trust assumptions and improves accountability.

------------------------------------------------------------------------

# 🛡 Security & Trust Architecture

1.  Multisig Owner (no single point of control)
2.  Hard-coded cooldowns
3.  Per-request caps
4.  Daily global cap
5.  Public action ledger
6.  Verified contracts on BaseScan

The system is designed to minimize maximum damage even under attack.

------------------------------------------------------------------------

# 🚀 Roadmap

## Phase 1 -- Grant Prototype

-   Deploy vault contract
-   Deploy soulbound NFT
-   Launch XMTP bot
-   Release transparency dashboard
-   Submit Base Builder Grant

## Phase 2 -- Social Experiment

-   Launch Base Mini-App
-   Add endorsement mechanism
-   Introduce donor tiers
-   Publish full action ledger

## Phase 3 -- Infrastructure Evolution

-   Modularize vault contracts
-   Publish SDK
-   Introduce governance
-   Enable custom score providers

------------------------------------------------------------------------

# 🤝 Contributing

Based Angel is open-source.

We welcome contributions in: - Smart contract optimization - Reputation
modules - Dashboard analytics - Security improvements - UX enhancements

------------------------------------------------------------------------

# 📜 License

MIT License

------------------------------------------------------------------------

# ⚡ Disclaimer

Based Angel is an experimental social coordination protocol.\
It does not guarantee eligibility or financial assistance.\
All disbursements are subject to on-chain constraints and reputation
thresholds.

------------------------------------------------------------------------

Built for Base.\
Programmable generosity, onchain.
