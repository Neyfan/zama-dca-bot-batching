# Zama Season 9 — Privacy-Preserving DCA Bot with Transaction Batching

A reference implementation for Zama Bounty Program — Season 9: build a privacy-preserving DCA bot with transaction batching using the Zama Protocol / fhEVM.

⚠️ This repo is scaffolded to help you ship fast. It includes:

- A confidential smart contract skeleton (`PrivateDCA.sol`) ready to use fhEVM encrypted types.
- A TypeScript bot that batches orders and submits encrypted inputs.
- A simple API + worker to queue & group orders, plus Docker setup.
- Tests, scripts, and a demo flow.

Replace all `TODO:` markers before submission.

---

## Quick start

### 1) Install toolchain
```bash
corepack enable # enables pnpm if available
pnpm i || npm i
```

### 2) Copy env
```bash
cp .env.example .env
# fill RPCs/keys; see .env.example
```

### 3) Compile & test
```bash
pnpm hardhat compile
pnpm test
```

### 4) Run local stack (API + worker)
```bash
docker compose up --build
```

### 5) Submit a sample batch
```bash
curl -X POST http://localhost:8787/api/order \
  -H 'content-type: application/json' \
  -d '{"asset":"WETH","amount":"1000000000000000","interval":"3600","recipient":"0x..."}'
```

---

## Project layout
```
contracts/
└─ PrivateDCA.sol              # fhEVM confidential DCA with batch settlement
scripts/
├─ deploy.ts                   # deploys contract
└─ demo.ts                     # submits demo encrypted batch
bot/
├─ batcher.ts                  # groups orders into batches & posts to contract
└─ crypto.ts                   # client-side FHE key mgmt & encryption helpers
api/
└─ server.ts                   # minimal API to collect DCA intents
test/
└─ PrivateDCA.spec.ts
docker-compose.yml
hardhat.config.ts
package.json
.env.example
README.md
```

---

## Bounty alignment (checklist)

- **Privacy**: amounts, schedule params, and recipients submitted as encrypted inputs using fhEVM encrypted types / API.  
- **Batching**: multiple DCA orders combined into one batched settlement onchain (gas-effective, single tx).  
- **Correctness**: unit tests for order creation, batching, and partial fills.  
- **UX**: REST endpoint + CLI demo + (optional) small web UI.  
- **Docs**: architecture & how to run.  
- **Video**: short demo walkthrough (≤3 min).

---

## Notes on Zama Protocol / fhEVM

This project targets the Zama confidential smart contract stack (often referred to as fhEVM). You will use encrypted types (`euint*`, `ebool`, etc.) and the provided precompiles/APIs to verify encrypted inputs and drive onchain logic with privacy.

**References:**

- [Zama Bounty Season 9 brief](https://www.zama.ai/post/zama-bounty-program-season-9)  
- fhEVM docs & examples  
- OpenZeppelin Confidential Contracts (optional)

---

## Submission data (for your convenience)

- **Email:** ncrypto@list.ru  
- **GitHub:** Neyfan  
- **Solution link:** [https://github.com/Neyfan/zama-dca-bot-batching](https://github.com/Neyfan/zama-dca-bot-batching)
