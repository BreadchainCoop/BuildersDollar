import { getPublicClient } from "@wagmi/core";

import { getConfig } from "@/chainConfig";
import { DISTRIBUTOR_ABI } from "@/abi";
import { useQuery } from "react-query";
import { Hex } from "viem";
import { useNetwork } from "wagmi";

type VoteLogData = {
  blockTimestamp: Hex;
  args: {
    holder: Hex;
    percentages: Array<bigint>;
    projects: Array<Hex>;
  };
};

export function useCurrentVotes(lastClaimedBlockNumber: bigint | null) {
  const { chain: activeChain } = useNetwork();
  const config = activeChain ? getConfig(activeChain.id) : getConfig("DEFAULT");
  const distributorAddress = config.DISBURSER.address;
  const publicClient = getPublicClient();

  console.log({ config });

  return useQuery({
    queryKey: "getVotesForCurrentRound",
    refetchInterval: 500,
    enabled: !!lastClaimedBlockNumber,
    queryFn: async () => {
      const logs = await publicClient.getContractEvents({
        address: distributorAddress,
        abi: DISTRIBUTOR_ABI,
        eventName: "BreadHolderVoted",
        fromBlock: lastClaimedBlockNumber || BigInt(0),
        toBlock: "latest",
      });
      const parsed = (logs as unknown as Array<VoteLogData>).map(parseVoteLog);
      return parsed;
    },
  });
}

export type ParsedVote = {
  account: Hex;
  blockTimestamp: number;
  points: number[];
  projects: Hex[];
};

function parseVoteLog(log: VoteLogData): ParsedVote {
  return {
    account: log.args.holder,
    blockTimestamp: 1000,
    points: log.args.percentages.map((bigPoints) => Number(bigPoints)),
    projects: log.args.projects,
  };
}

function pointsToPermyraid(points: Array<number>) {
  const total = points.reduce((acc, num) => acc + num, 0);
  return points.map((p) => Math.floor((p * 10000) / total));
}
