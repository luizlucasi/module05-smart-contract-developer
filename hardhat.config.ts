import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.27",
  networks: {
    sepolia: {
      url: 'https://shape-mainnet.g.alchemy.com/v2/QVP6zs1zABCVBo9XerQ4MOyVGei_b52m',
      accounts: ["0x948f79c5ca5cb883fda815fa844edf6c88544207e365cfb8af0d8d9d76cb364e"]
    }
  },
  etherscan: {

  }
};

export default config;
