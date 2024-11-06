import { DISTRIBUTOR_ABI } from "@/abi";
import { getConfig } from "@/chainConfig";
import { useEffect, useState } from "react";
import { useContractRead, useNetwork } from "wagmi";
import { TConnectedUserState } from "../core/hooks/useConnectedUser";
import { formatUnits } from "viem";
import { CycleLengthState, useCycleLength } from "./useCycleLength";

type UserVotingPowerState =
  | {
      status: "ACTUAL";
      value: number;
    }
  | {
      status: "NOMINAL";
      value: number;
    };

export function useUserVotingPower(
  user: TConnectedUserState,
  cycleLength: CycleLengthState
) {
  const [userVotingPower, setUserVotingPower] = useState<number | null>(null);

  const { chain: activeChain } = useNetwork();
  const config = activeChain ? getConfig(activeChain.id) : getConfig("DEFAULT");
  const distributorAddress = config.DISBURSER.address;

  const {
    data: currentVotingPowerData,
    status: currentVotingPowerStatus,
    error: currentVotingPowerError,
  } = useContractRead({
    enabled: user.status === "CONNECTED" && distributorAddress !== "0x",
    address: distributorAddress,
    abi: DISTRIBUTOR_ABI,
    functionName: "getCurrentVotingPower",
    args: [user.status === "CONNECTED" ? user.address : ""],
  });

  useEffect(() => {
    if (currentVotingPowerStatus === "error" && currentVotingPowerError) {
      console.error(currentVotingPowerError);
    }
    if (
      currentVotingPowerStatus === "success" &&
      currentVotingPowerData !== null &&
      cycleLength.status === "SUCCESS"
    ) {
      const vp = Number(formatUnits(currentVotingPowerData as bigint, 18));
      setUserVotingPower(vp);
    }
  }, [
    currentVotingPowerStatus,
    currentVotingPowerData,
    currentVotingPowerError,
    cycleLength,
  ]);

  return { userVotingPower };
}
