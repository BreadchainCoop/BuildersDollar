import { configureChains, createConfig } from "wagmi";
import { jsonRpcProvider } from "wagmi/providers/jsonRpc";

import { hardhat } from "wagmi/chains";
import { connectorsForWallets } from "@rainbow-me/rainbowkit";

import { publicProvider } from "wagmi/providers/public";
import { getWallets } from "./wallets";

const WALLET_CONNECT_PROJECT_ID =
  process.env.NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID;
if (!WALLET_CONNECT_PROJECT_ID)
  throw new Error("WALLET_CONNECT_PROJECT_ID not set!");

const chainsConfig = configureChains(
  [{ ...hardhat, id: 31337 }],
  [
    publicProvider(),
    jsonRpcProvider({
      rpc: () => ({
        http: "http://localhost:8545",
        webSocket: "ws://localhost:8545",
      }),
    }),
  ]
);

const { chains } = chainsConfig;

const { publicClient } = chainsConfig;

const projectId = WALLET_CONNECT_PROJECT_ID;

const connectors = connectorsForWallets([
  {
    groupName: "Other",
    wallets: getWallets(chains, projectId),
  },
]);

const config = createConfig({
  autoConnect: true,
  connectors,
  publicClient,
});

export { chains, config };
