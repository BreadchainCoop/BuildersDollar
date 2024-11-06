import { createPublicClient, http } from "viem";
import { BREAD_ABI } from "../src/abi";
import { BREAD_ADDRESS } from "../src/chainConfig";
import fs from "fs";
import path from "path";
import { gnosis } from "viem/chains";

const publicClient = createPublicClient({
  chain: gnosis,
  transport: http(),
});

async function main() {
  let lastVal;

  setInterval(async () => {
    const res = await publicClient.readContract({
      address: BREAD_ADDRESS,
      abi: BREAD_ABI,
      functionName: "yieldAccrued",
    });
    if (res !== lastVal) {
      await fs.promises.appendFile(
        path.join(__dirname, "vals.txt"),
        `${new Date(Date.now()).toTimeString()} :: ${res}\n`
      );
      lastVal = res;
    }

    console.log(`yieldAccrued - ${res}`);
  }, 1000);
}

main();
