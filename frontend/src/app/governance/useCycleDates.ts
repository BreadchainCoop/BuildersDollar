import { DISTRIBUTOR_ABI } from "@/abi";
import { getConfig } from "@/chainConfig";
import { useEffect, useState } from "react";
import { useBlockNumber, useContractRead, useNetwork } from "wagmi";
import { add, sub } from "date-fns";
import { CycleLengthState } from "./useCycleLength";

export type CycleDatesLoading = {
  status: "LOADING";
};
export type CycleDatesSuccess = {
  status: "SUCCESS";
  start: Date;
  end: Date;
};
export type CycleDatesError = {
  status: "ERROR";
};

export type CycleDatesState =
  | CycleDatesLoading
  | CycleDatesSuccess
  | CycleDatesError;

export function useCycleDates(cycleLength: CycleLengthState) {
  const [cycleDates, setCycleDates] = useState<CycleDatesState>({
    status: "LOADING",
  });

  const { chain: activeChain } = useNetwork();
  const config = activeChain ? getConfig(activeChain.id) : getConfig("DEFAULT");
  const distributorAddress = config.DISBURSER.address;

  const {
    data: lastClaimedBlockNumberData,
    status: lastClaimedBlockNumberStatus,
  } = useContractRead({
    address: distributorAddress,
    abi: DISTRIBUTOR_ABI,
    functionName: "lastClaimedBlockNumber",
    watch: true,
  });

  const { data: currentBlockNumberData, status: currentBlockNumberStatus } =
    useBlockNumber();

  useEffect(() => {
    if (
      lastClaimedBlockNumberStatus === "error" ||
      currentBlockNumberStatus === "error" ||
      lastClaimedBlockNumberData ||
      cycleLength !== null
    ) {
    }
    if (
      lastClaimedBlockNumberStatus === "success" &&
      lastClaimedBlockNumberData &&
      cycleLength.status === "SUCCESS" &&
      currentBlockNumberStatus === "success" &&
      currentBlockNumberData
    ) {
      const secondsSinceStart =
        (Number(currentBlockNumberData) - Number(lastClaimedBlockNumberData)) *
        5;
      const cycleBlocksRemaining =
        Number(lastClaimedBlockNumberData) +
        cycleLength.data -
        Number(currentBlockNumberData);
      const cycleSecondsRemaining = cycleBlocksRemaining * 5;
      setCycleDates({
        status: "SUCCESS",
        start: sub(new Date(), { seconds: secondsSinceStart }),
        end: add(new Date(), {
          seconds: cycleSecondsRemaining,
        }),
      });
    }
  }, [
    lastClaimedBlockNumberData,
    lastClaimedBlockNumberStatus,
    cycleLength,
    currentBlockNumberData,
    currentBlockNumberStatus,
  ]);

  return { cycleDates };
}
