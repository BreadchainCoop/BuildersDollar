import { useEffect, useState } from "react";
import { useContractRead, useNetwork } from "wagmi";

import { DISTRIBUTOR_ABI } from "@/abi";
import { getConfig } from "@/chainConfig";
import { formatUnits } from "viem";

export function useMinRequiredVotingPower() {
  const [minRequiredVotingPower, setMinRequiredVotingPower] = useState<
    number | null
  >(null);

  const { chain: activeChain } = useNetwork();
  const config = activeChain ? getConfig(activeChain.id) : getConfig("DEFAULT");
  const distributorAddress = config.DISBURSER.address;

  const {
    data: minRequiredVotingPowerData,
    status: minRequiredVotingPowerStatus,
  } = useContractRead({
    address: distributorAddress,
    abi: DISTRIBUTOR_ABI,
    functionName: "minRequiredVotingPower",
    watch: true,
  });

  useEffect(() => {
    if (
      minRequiredVotingPowerStatus === "success" &&
      minRequiredVotingPowerData
    ) {
      setMinRequiredVotingPower(
        Number(formatUnits(minRequiredVotingPowerData as bigint, 18))
      );
    }
  }, [minRequiredVotingPowerStatus, minRequiredVotingPowerData]);

  return { minRequiredVotingPower };
}
