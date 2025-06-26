# 🏦 T-Pay Exchange

T-Pay Exchange is a decentralized exchange (DEX) built on Solidity and deployed using Hardhat. Inspired by Uniswap, it features a factory contract pattern and is extendable to include token pair creation, liquidity management, and swaps.

---

## 📦 Tech Stack

- Solidity (v0.8.x)
- Hardhat — Development framework
- Ethers.js — For contract interaction
- Chai/Mocha — For testing
- Hardhat Ignition — Deployment orchestration
- dotenv — For environment variables

---

## 📁 Project Structure

```
Tpay-Exchange/
├── contracts/            # Solidity smart contracts
├── test/                 # Unit tests using Chai
├── scripts/              # Optional deploy or utility scripts
├── ignition/             # Hardhat Ignition deployment modules
├── .env                  # Private env variables (not committed)
├── .env.example          # Sample file showing env variable names
├── hardhat.config.js     # Hardhat config
├── package.json          # Dependencies and scripts
```

---

## ⚙️ Environment Setup

### 1. Clone the Repository

```bash
git clone https://github.com/CSPratishtha/TPay-exchange.git
cd TPay-exchange
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Setup Environment Variables

Create a `.env` file in the root directory.  
All required credentials and variable names are listed in the `.env.example` file.

```bash
cp .env.example .env
```

> ⚠️ Never commit your `.env` file — it’s excluded via `.gitignore`.

---

## 🚀 Usage Guide

### ✅ Compile Contracts

```bash
npx hardhat compile
```

### 🧪 Run Tests

```bash
npx hardhat test
```

With gas report:

```bash
REPORT_GAS=true 
```

### 🌐 Run Local Hardhat Node

```bash
npx hardhat node
```

### 📦 Deploy Using Hardhat Ignition

```bash
npx hardhat ignition deploy ./ignition/modules/Lock.js
```

> Replace `Lock.js` with your deployment file (e.g. `TpayFactory.js`) if applicable.




