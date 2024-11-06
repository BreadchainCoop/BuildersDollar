import { createPublicClient, http, parseAbiItem } from "viem";
import { foundry, gnosis } from "viem/chains";

import { getConfig } from "../src/chainConfig";

import { DISTRIBUTOR_ABI } from "../src/abi";

async function main() {
  const publicClient = createPublicClient({
    chain: gnosis,
    transport: http(),
  });

  const config = getConfig(100);

  // const logs = await publicClient.getContractEvents({
  //   address: config.DISBURSER.address,
  //   abi: DISTRIBUTOR_ABI,
  //   // eventName: "YieldDistributed",
  //   fromBlock: BigInt(34695057),
  //   toBlock: "latest",
  // });

  const logs = await publicClient.getLogs({
    address: config.DISBURSER.address,
    event: parseAbiItem("event YieldDistributed(uint256, uint256, uint256[])"),
    // args: {
    //   from: "0xd8da6bf26964af9d7eed9e03e53415d37aa96045",
    //   to: "0xa5cc3c03994db5b0d9a5eedd10cabab0813678ac",
    // },
    fromBlock: BigInt(34695057),
    toBlock: "latest",
  });

  return logs;
}

main();
