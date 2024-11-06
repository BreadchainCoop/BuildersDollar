import { MockConnector } from "wagmi/connectors/mock";
import { Chain, Hex, createWalletClient, http } from "viem";
import { hardhat } from "viem/chains";

export function mockWallet(
  chains: Chain[],
  id: string,
  name: string,
  account: Hex,
  key: Hex
) {
  return {
    id,
    name,
    iconUrl: "",
    iconBackground: "",
    createConnector() {
      const connector = new MockConnector({
        chains,
        options: {
          walletClient: createWalletClient({
            transport: http("http://localhost:8545"),
            chain: hardhat,
            account,
            key,
            pollingInterval: 100,
          }),
        },
      });
      return { connector };
    },
  };
}
