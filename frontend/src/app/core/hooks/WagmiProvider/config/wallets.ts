import {
  frameWallet,
  injectedWallet,
  metaMaskWallet,
  walletConnectWallet,
} from "@rainbow-me/rainbowkit/wallets";
import { Chain } from "wagmi";

export function getWallets(chains: Chain[], projectId: string) {
  return [
    injectedWallet({ chains, projectId, appName: "Breadchain Crowdstaking" }),
    metaMaskWallet({ chains, projectId }),
    walletConnectWallet({ chains, projectId }),
    frameWallet({ chains, projectId }),
  ];
}
