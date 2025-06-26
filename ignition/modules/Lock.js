const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const TEAM_WALLET = "0xF0a83ba20A16A93161262bE2cD71bc4d626C08a0";       
const MARKETING_WALLET = "0xb178512aA2C4D0c3C43a12c7b7C2d1465fe298A5"; 
const ADMIN = "0x4F02C3102A9D2e1cC0cC97c7fE2429B9B6F5965D" 
const TPAY_PER_BLOCK = "1000000000000000000"; 
const START_BLOCK = 0; 
module.exports = buildModule("TpaySystemModule", (m) => {
  // Step 1: Deploy TPAY token
  const token = m.contract("TpayToken", [TEAM_WALLET, MARKETING_WALLET]);

  // Step 2: Deploy Factory
  const factory = m.contract("TpayFactory", [ADMIN]);

  // Step 3: Deploy Farm with TPAY address
  const farm = m.contract("TpayFarm", [
    token,         // address of deployed TpayToken
    TPAY_PER_BLOCK,
    START_BLOCK,
  ]);

  // Step 4: Deploy Router with Factory address
  const router = m.contract("TpayRouter", [factory]);

  return { token, factory, farm, router };
});


// npx hardhat ignition deploy ./ignition/modules/Lock.js --network bsc-testnet
// npx hardhat ignition verify chain-11155111

