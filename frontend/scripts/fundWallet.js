const hre = require("hardhat");

const ABI = require("../src/abi/ERC20.json");

require("dotenv").config();

const contracts = {
  DAI: {
    symbol: "DAI",
    decimals: 18,
    address: "0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063",
  },
  BREAD: {
    symbol: "BREAD",
    decimals: 18,
    address: "0x11d9efDf4Ab4A3bfabf5C7089F56AA4F059AA14C",
  },
};

const addressWithDAI = "0xd6b26861139a52877Cd7adc437Edd7c5383fF585";

const fundAccount = async ({ address, name }) => {
  const sourceSigner = await hre.ethers.getImpersonatedSigner(addressWithDAI);

  const DAIcontract = new hre.ethers.Contract(
    contracts.DAI.address,
    ABI,
    sourceSigner
  );

  await DAIcontract.transfer(address, hre.ethers.utils.parseEther("20000.00"));

  let DAIbalanceNEW = await DAIcontract.balanceOf(address);
  const parsedDAIbalanceNEW = hre.ethers.utils.formatUnits(DAIbalanceNEW, 18);

  console.log(
    `transfer complete -> ${name} wallet DAI balance: `,
    parsedDAIbalanceNEW
  );
};

const main = async () => {
  const accounts = [
    {
      name: "hardhat1",
      address: "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
    },
    {
      name: "hardhat2",
      address: "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
    },
    {
      name: "hardhat3",
      address: "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC",
    },
  ];

  setTimeout(async () => {
    await fundAccount(accounts[0]);
  }, 3000);
};

main();
