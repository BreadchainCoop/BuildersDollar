import { BREAD_ABI } from "../src/abi";
import { BREAD_ADDRESS } from "../src/chainConfig";
import { publicClient, testClient } from "./lib";

async function createCheckpoint() {
  await testClient.impersonateAccount({
    address: "0x458cD345B4C05e8DF39d0A07220feb4Ec19F5e6f",
  });

  try {
    const hash = await testClient.writeContract({
      account: "0x458cD345B4C05e8DF39d0A07220feb4Ec19F5e6f",
      address: BREAD_ADDRESS,
      abi: BREAD_ABI,
      functionName: "mint",
      value: 1n,
      args: ["0x458cd345b4c05e8df39d0a07220feb4ec19f5e6f"],
    });

    const transaction = await publicClient.waitForTransactionReceipt({ hash });

    console.log(`baked 1 wei of bread`);
  } catch (err) {
    console.log(err);
  }
}

createCheckpoint();
