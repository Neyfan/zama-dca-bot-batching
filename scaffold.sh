#!/usr/bin/env bash
set -euo pipefail

# Repo name and basic metadata
REPO_NAME="zama-dca-bot-batching"
GITHUB_USER="Neyfan"
AUTHOR_EMAIL="ncrypto@list.ru"
LICENSE_HOLDER="${GITHUB_USER}"

mkdir -p "$REPO_NAME" && cd "$REPO_NAME"

echo "Initializing repo: $REPO_NAME"

git init >/dev/null 2>&1 || true

# --- .gitignore ---
cat > .gitignore << 'EOF'
# Node
node_modules
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.pnpm-store

# Env
.env
.env.*

# Python
.venv
__pycache__
*.pyc

# Hardhat/Foundry/Artifacts
artifacts
cache
out
coverage
coverage.json

# OS
.DS_Store
Thumbs.db
EOF

# --- LICENSE (MIT) ---
cat > LICENSE << EOF
MIT License

Copyright (c) $(date +%Y) ${LICENSE_HOLDER}

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

# --- README.md ---
cat > README.md << 'EOF'
# Zama Season 9 — Privacy-Preserving DCA Bot with Transaction Batching

A reference implementation for **Zama Bounty Program — Season 9**: build a privacy-preserving DCA bot with transaction batching using the **Zama Protocol / fhEVM**.

> ⚠️ This repo is scaffolded to help you ship fast. It includes:
> - A confidential smart contract skeleton (`PrivateDCA.sol`) ready to use **fhEVM encrypted types**.
> - A TypeScript bot that batches orders and submits encrypted inputs.
> - A simple API + worker to queue & group orders, plus Docker setup.
> - Tests, scripts, and a demo flow.
>
> Replace all `TODO:` markers before submission.

## Quick start

```bash
# 1) Install toolchain
corepack enable # enables pnpm if available
pnpm i || npm i

# 2) Copy env
cp .env.example .env
# fill RPCs/keys; see .env.example

# 3) Compile & test
pnpm hardhat compile
pnpm test

# 4) Run local stack (API + worker)
docker compose up --build

# 5) Submit a sample batch
curl -X POST http://localhost:8787/api/order \
  -H 'content-type: application/json' \
  -d '{"asset":"WETH","amount":"1000000000000000","interval":"3600","recipient":"0x..."}'
```

## Project layout

```
├─ contracts/
│  └─ PrivateDCA.sol              # fhEVM confidential DCA with batch settlement
├─ scripts/
│  ├─ deploy.ts                   # deploys contract
│  └─ demo.ts                     # submits demo encrypted batch
├─ bot/
│  ├─ batcher.ts                  # groups orders into batches & posts to contract
│  └─ crypto.ts                   # client-side FHE key mgmt & encryption helpers
├─ api/
│  └─ server.ts                   # minimal API to collect DCA intents
├─ test/
│  └─ PrivateDCA.spec.ts
├─ docker-compose.yml
├─ hardhat.config.ts
├─ package.json
├─ .env.example
└─ README.md
```

## Bounty alignment (checklist)
- [ ] Privacy: amounts, schedule params, and recipients submitted as **encrypted inputs** using fhEVM encrypted types / API.
- [ ] Batching: multiple DCA orders combined into one **batched settlement** onchain (gas-effective, single tx).
- [ ] Correctness: unit tests for order creation, batching, and partial fills.
- [ ] UX: REST endpoint + CLI demo + (optional) small web UI.
- [ ] Docs: architecture & how to run.
- [ ] Video: short demo walkthrough (≤3 min).

## Notes on Zama Protocol / fhEVM
This project targets the Zama confidential smart contract stack (often referred to as **fhEVM**). You will use encrypted types (`euint*`, `ebool`, etc.) and the provided precompiles/APIs to verify encrypted inputs and drive onchain logic with privacy.

> References:
> - Zama Bounty Season 9 brief
> - fhEVM docs & examples
> - OpenZeppelin Confidential Contracts (optional)

---

### Submission data (for your convenience)
- **Email:** ncrypto@list.ru
- **GitHub:** Neyfan
- **Solution link:** https://github.com/Neyfan/zama-dca-bot-batching

EOF

# --- package.json ---
cat > package.json << 'EOF'
{
  "name": "zama-dca-bot-batching",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "build": "hardhat compile",
    "test": "hardhat test",
    "deploy": "hardhat run scripts/deploy.ts --network localhost",
    "demo": "ts-node scripts/demo.ts",
    "api": "ts-node api/server.ts",
    "bot": "ts-node bot/batcher.ts"
  },
  "devDependencies": {
    "@nomicfoundation/hardhat-toolbox": "^5.0.0",
    "@types/node": "^20.11.0",
    "dotenv": "^16.4.5",
    "hardhat": "^2.22.5",
    "ts-node": "^10.9.2",
    "typescript": "^5.5.4"
  },
  "dependencies": {
    "axios": "^1.7.2",
    "express": "^4.19.2",
    "p-limit": "^6.1.0"
  }
}
EOF

# --- tsconfig.json ---
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "strict": true,
    "esModuleInterop": true,
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "outDir": "dist",
    "types": ["node", "hardhat"]
  },
  "include": ["./**/*.ts"]
}
EOF

# --- .env.example ---
cat > .env.example << 'EOF'
# RPCs / Keys
RPC_URL=http://localhost:8545
PRIVATE_KEY=0xYOUR_PRIVATE_KEY
CONTRACT_ADDRESS=

# API
PORT=8787
EOF

# --- hardhat.config.ts ---
cat > hardhat.config.ts << 'EOF'
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from "dotenv";
dotenv.config();

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: { enabled: true, runs: 200 }
    }
  },
  networks: {
    localhost: { url: process.env.RPC_URL || "http://127.0.0.1:8545" }
  }
};

export default config;
EOF

# --- contracts/PrivateDCA.sol ---
mkdir -p contracts
cat > contracts/PrivateDCA.sol << 'EOF'
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// NOTE: Placeholder imports — replace with actual fhEVM/confidential types once integrating.
// import { euint64, ebool, FHE } from "@zama/fhevm/Confidential.sol";

/**
 * @title PrivateDCA
 * @notice Confidential DCA with transaction batching using Zama Protocol (fhEVM).
 * @dev This is a skeleton to be adapted to actual fhEVM encrypted types & APIs.
 */
contract PrivateDCA {
    struct EncOrder {
        // TODO: replace bytes with encrypted types (e.g., euint64)
        bytes encAmount;      // encrypted amount per slice
        bytes encInterval;    // encrypted seconds
        bytes encRecipient;   // encrypted address
        address asset;        // public: asset being purchased
        address payer;        // public: who funds the DCA
        uint64 createdAt;     // public: timestamp (ok to be public)
    }

    // Orders stored by id
    uint256 public nextOrderId;
    mapping(uint256 => EncOrder) public orders;

    event OrderCreated(uint256 indexed orderId, address indexed payer, address asset);
    event BatchExecuted(uint256[] orderIds, address indexed executor);

    function createOrder(
        bytes calldata encAmount,
        bytes calldata encInterval,
        bytes calldata encRecipient,
        address asset
    ) external returns (uint256 oid) {
        oid = nextOrderId++;
        orders[oid] = EncOrder({
            encAmount: encAmount,
            encInterval: encInterval,
            encRecipient: encRecipient,
            asset: asset,
            payer: msg.sender,
            createdAt: uint64(block.timestamp)
        });
        emit OrderCreated(oid, msg.sender, asset);
    }

    /**
     * @notice Execute a batch of DCA orders in a single transaction.
     * @dev TODO: integrate FHE decryption proofs / coprocessor calls and AMM swap logic.
     */
    function executeBatch(uint256[] calldata orderIds, bytes[] calldata encNow) external {
        require(orderIds.length == encNow.length, "LEN");
        // TODO: verify timings using encrypted comparisons, compute amounts, perform swaps.
        emit BatchExecuted(orderIds, msg.sender);
    }
}
EOF

# --- scripts/deploy.ts ---
mkdir -p scripts
cat > scripts/deploy.ts << 'EOF'
import { ethers } from "hardhat";

async function main() {
  const Factory = await ethers.getContractFactory("PrivateDCA");
  const contract = await Factory.deploy();
  await contract.deployed();
  console.log("PrivateDCA deployed:", contract.address);
}

main().catch((e) => { console.error(e); process.exit(1); });
EOF

# --- scripts/demo.ts ---
cat > scripts/demo.ts << 'EOF'
import "dotenv/config";
import { ethers } from "hardhat";

// Fake encryption helpers for demo; replace with fhEVM client SDK
function enc(bytes: string) { return bytes; }

async function run() {
  const [signer] = await ethers.getSigners();
  const addr = process.env.CONTRACT_ADDRESS;
  if (!addr) throw new Error("Set CONTRACT_ADDRESS in .env");
  const dca = await ethers.getContractAt("PrivateDCA", addr);

  const tx = await dca.connect(signer).createOrder(
    enc("0x01"), // encAmount placeholder
    enc("0x02"), // encInterval placeholder
    enc("0x03"), // encRecipient placeholder
    "0x0000000000000000000000000000000000000000" // asset placeholder
  );
  const rc = await tx.wait();
  console.log("Submitted createOrder, tx:", rc?.transactionHash);
}

run().catch((e) => { console.error(e); process.exit(1); });
EOF

# --- api/server.ts ---
mkdir -p api
cat > api/server.ts << 'EOF'
import "dotenv/config";
import express from "express";
import { enqueueOrder } from "../bot/batcher";

const app = express();
app.use(express.json());

app.post("/api/order", async (req, res) => {
  try {
    const { asset, amount, interval, recipient } = req.body || {};
    if (!asset || !amount || !interval || !recipient) {
      return res.status(400).json({ error: "asset, amount, interval, recipient required" });
    }
    await enqueueOrder({ asset, amount, interval, recipient });
    res.json({ ok: true });
  } catch (e:any) {
    res.status(500).json({ error: e.message });
  }
});

const port = Number(process.env.PORT || 8787);
app.listen(port, () => console.log(`API listening on :${port}`));
EOF

# --- bot/crypto.ts ---
mkdir -p bot
cat > bot/crypto.ts << 'EOF'
// TODO: Replace with fhEVM client encryption + KMS API integration.
export function encryptAmount(wei: string): string { return "0x01"; }
export function encryptInterval(sec: string): string { return "0x02"; }
export function encryptRecipient(addr: string): string { return "0x03"; }
EOF

# --- bot/batcher.ts ---
cat > bot/batcher.ts << 'EOF'
import "dotenv/config";
import { encryptAmount, encryptInterval, encryptRecipient } from "./crypto";
import { ethers } from "hardhat";

export type Order = { asset: string; amount: string; interval: string; recipient: string };

const queue: Order[] = [];

export async function enqueueOrder(o: Order) {
  queue.push(o);
}

async function flushBatch() {
  if (queue.length === 0) return;
  const orders = queue.splice(0, queue.length);
  console.log(`Flushing batch with ${orders.length} orders`);

  const addr = process.env.CONTRACT_ADDRESS;
  if (!addr) throw new Error("Set CONTRACT_ADDRESS in .env");
  const dca = await (await import("hardhat")).ethers.getContractAt("PrivateDCA", addr);

  const encAmts = orders.map(o => encryptAmount(o.amount));
  const encIntervals = orders.map(o => encryptInterval(o.interval));
  const encRecipients = orders.map(o => encryptRecipient(o.recipient));

  // For the demo, submit one by one (safer). Replace with a single executeBatch call.
  for (let i = 0; i < orders.length; i++) {
    const tx = await dca.createOrder(encAmts[i], encIntervals[i], encRecipients[i], orders[i].asset);
    await tx.wait();
  }

  // TODO: call dca.executeBatch([...orderIds], [...encNow]) once fhEVM encrypted ops are wired.
}

setInterval(() => { flushBatch().catch(console.error); }, 10_000);
EOF

# --- test/PrivateDCA.spec.ts ---
mkdir -p test
cat > test/PrivateDCA.spec.ts << 'EOF'
import { expect } from "chai";
import { ethers } from "hardhat";

describe("PrivateDCA", () => {
  it("stores orders and emits events", async () => {
    const Factory = await ethers.getContractFactory("PrivateDCA");
    const dca = await Factory.deploy();
    await dca.deployed();

    const tx = await dca.createOrder("0x01", "0x02", "0x03", ethers.ZeroAddress);
    const rc = await tx.wait();
    expect(rc?.logs?.length).to.be.greaterThan(0);

    const order = await dca.orders(0);
    expect(order.asset).to.equal(ethers.ZeroAddress);
  });
});
EOF

# --- Docker setup ---
cat > Dockerfile << 'EOF'
FROM node:20-alpine
WORKDIR /app
COPY package.json pnpm-lock.yaml* package-lock.json* yarn.lock* ./
RUN npm i -g pnpm || true && (pnpm i || npm i)
COPY . .
EXPOSE 8787
CMD ["npm","run","api"]
EOF

cat > docker-compose.yml << 'EOF'
services:
  api:
    build: .
    env_file: .env
    ports:
      - "8787:8787"
    command: ["npm","run","api"]
  bot:
    build: .
    env_file: .env
    command: ["npm","run","bot"]
    depends_on:
      - api
EOF

# --- repo-local checklist ---
cat > SUBMISSION-CHECKLIST.md << 'EOF'
# Submission Checklist (Season 9)

- [ ] Replace placeholders with real fhEVM encrypted types & client SDK calls.
- [ ] Implement `executeBatch` with encrypted time checks & amount math.
- [ ] Integrate an AMM (e.g., Uniswap-style router) or mock for swaps.
- [ ] Record gas savings vs single-order execution.
- [ ] Add a 2–3 minute demo video link here.
- [ ] Update README with deployment instructions and network details.
- [ ] Push to GitHub: https://github.com/Neyfan/zama-dca-bot-batching
EOF

printf "\nRepo scaffolded. Next steps:\n  1) cd %s\n  2) git add . && git commit -m 'init: zama s9 private dca bot scaffold'\n  3) Create repo on GitHub (%s/%s) and push.\n\n" "$REPO_NAME" "$GITHUB_USER" "$REPO_NAME"
