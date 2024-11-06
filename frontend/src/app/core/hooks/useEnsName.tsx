import { useEffect, useState } from "react";
import { Address, createPublicClient, http } from "viem";
import { mainnet } from "viem/chains";

const ALCHEMY_MAINNET_API_KEY = process.env.NEXT_PUBLIC_ALCHEMY_MAINNET_API_KEY;
if (!ALCHEMY_MAINNET_API_KEY)
  throw new Error("ALCHEMY_MAINNET_API_KEY not set!");

export const publicClient = createPublicClient({
  chain: mainnet,
  transport: http(
    `https://eth-mainnet.g.alchemy.com/v2/${ALCHEMY_MAINNET_API_KEY}`
  ),
});

export type TEnsNameLoading = { status: "LOADING" };
export type TEnsNameError = { status: "ERROR" };
export type TEnsNameSuccess = { status: "SUCCESS"; ensName: string | null };

export type TEnsNameState = TEnsNameLoading | TEnsNameError | TEnsNameSuccess;

export function useEnsName(address: string) {
  const [value, setValue] = useState<TEnsNameState>({ status: "LOADING" });
  const [currentAddress, setcurrentAddress] = useState<string | null>(null);
  // TODO need to refetch when address changes
  useEffect(() => {
    async function fetchEnsName() {
      const result = await publicClient.getEnsName({
        address: address as Address,
      });
      setValue({ status: "SUCCESS", ensName: result });
    }
    if (address !== currentAddress) {
      setcurrentAddress(address);
      setValue({ status: "LOADING" });
      return;
    }
    if (value.status !== "LOADING" && address === currentAddress) return;
    fetchEnsName();
  }, [address, currentAddress, value, setValue, setcurrentAddress]);

  return value;
}
