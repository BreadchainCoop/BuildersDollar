import { configureChains, createConfig } from "wagmi";
import { jsonRpcProvider } from "wagmi/providers/jsonRpc";

import { gnosis, sepolia } from "wagmi/chains";
import { connectorsForWallets } from "@rainbow-me/rainbowkit";

import { publicProvider } from "wagmi/providers/public";
import { getWallets } from "./wallets";
import { SafeConnector } from "wagmi/connectors/safe";
import { mockWallet } from "./mockWallet";

const NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID =
  process.env.NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID;
if (!NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID)
  throw new Error("NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID not set!");

const NEXT_PUBLIC_QUIKNODE_URL = process.env.NEXT_PUBLIC_QUIKNODE_URL;
if (!NEXT_PUBLIC_QUIKNODE_URL)
  throw new Error("NEXT_PUBLIC_QUIKNODE_URL not set!");

const chainsConfig = configureChains(
  [
    {
      ...gnosis,
      iconUrl: "gnosis_icon.svg",
    },
    ...(process.env.NEXT_PUBLIC_TESTNET === "true" ? [sepolia] : []),
  ],
  [
    publicProvider(),
    jsonRpcProvider({
      rpc: () => ({
        http:
          process.env.NEXT_PUBLIC_TESTNET === "true"
            ? sepolia.rpcUrls.default.http[0]
            : NEXT_PUBLIC_QUIKNODE_URL,
      }),
    }),
  ]
);

const { chains } = chainsConfig;

const { publicClient } = chainsConfig;

const projectId = NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID;

const connectors = connectorsForWallets([
  {
    groupName: "Wallets",
    wallets: process.env.CI
      ? [
          ...getWallets(chains, projectId),
          mockWallet(
            chains,
            "mock1",
            "Mock Wallet 1",
            "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
            "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
          ),
        ]
      : [...getWallets(chains, projectId)],
  },
]);

const config = createConfig({
  autoConnect: true,
  connectors: [
    ...connectors(),
    new SafeConnector({
      chains,
      options: {
        allowedDomains: [/app.safe.global$/],
        debug: false,
      },
    }),
  ],
  publicClient,
});

export { chains as prodChains, config as prodConfig };
