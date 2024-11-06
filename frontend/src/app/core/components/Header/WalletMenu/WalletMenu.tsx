import { type ReactNode } from "react";
import Image from "next/image";
import { Hex } from "viem";
import * as NavigationMenu from "@radix-ui/react-navigation-menu";
import { blo } from "blo";

import { truncateAddress } from "@/app/core/util/formatter";
import { TEnsNameState, useEnsName } from "@/app/core/hooks/useEnsName";
import { WalletDisconnectButton } from "./WalletDisconnectButton";
import { useWatchAsset } from "@/app/core/hooks/useWatchAsset";
import { BreadIcon } from "../../Icons/TokenIcons";

export function Row({ children }: { children: ReactNode }) {
  return (
    <span className="flex items-center justify-center gap-4 text-center text-xs md:justify-end">
      {children}
    </span>
  );
}

interface IProps {
  account: {
    address: string;
    displayName: string;
  };
  chainString: string;
  handleDisconnect: () => void;
}

export function WalletMenu({ account, handleDisconnect, chainString }: IProps) {
  const ensNameResult = useEnsName(account.address);
  return (
    <WalletMenuContent
      account={account}
      chainString={chainString}
      handleDisconnect={handleDisconnect}
      ensNameResult={ensNameResult}
    />
  );
}

export function WalletMenuContent({
  account,
  handleDisconnect,
  ensNameResult,
}: {
  account: { address: string; displayName: string };
  handleDisconnect: () => void;
  chainString: string;
  ensNameResult: TEnsNameState;
}) {
  function preventHover(event: any) {
    event.preventDefault();
  }

  const { watchAsset } = useWatchAsset();

  return (
    <NavigationMenu.Root className="relative">
      <NavigationMenu.List>
        <NavigationMenu.Item>
          <NavigationMenu.Trigger
            onPointerMove={preventHover}
            onPointerLeave={preventHover}
            className="px-4 py-2 flex items-center gap-2 rounded-full bg-breadgray-ultra-white dark:bg-breadgray-charcoal text-breadgray-grey100 dark:text-breadgray-grey dark:hover:bg-breadgray-og-dark dark:hover:text-neutral-300"
          >
            <span
              className={
                "flex w-full gap-4 items-center justify-center truncate text-ellipsis md:justify-end"
              }
            >
              {(() => {
                switch (ensNameResult.status) {
                  case "LOADING":
                    return null;
                  case "SUCCESS":
                    return (
                      <>
                        <div className="rounded-full overflow-clip w-6 h-6">
                          <Image
                            src={blo(account.address as Hex)}
                            alt="ens avatar"
                            width="24"
                            height="24"
                            className="transform scale-110"
                          />
                        </div>
                        {ensNameResult.ensName ||
                          truncateAddress(account.address)}
                      </>
                    );
                }
              })()}
            </span>
          </NavigationMenu.Trigger>
          <NavigationMenu.Content
            onPointerEnter={preventHover}
            onPointerLeave={preventHover}
          >
            <div className="bg-breadgray-ultra-white dark:bg-breadgray-charcoal border border-breadgray-grey dark:border-none rounded p-4 text-xs flex flex-col items-end gap-4">
              <button
                onClick={() => {
                  navigator.clipboard
                    .writeText(account.address)
                    .catch((err): void => {
                      console.error(err);
                    });
                }}
                title="copy address"
                className="text-neutral-400 hover:text-neutral-300 text-base font-bold tracking-wider flex gap-4 items-center active:underline"
              >
                <span>{truncateAddress(account.address)}</span>
                <svg
                  className="fill-current w-4 h-4"
                  viewBox="0 0 16 20"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <path
                    fillRule="evenodd"
                    clipRule="evenodd"
                    d="M0 0H11V2H2V15H0V0ZM4 4H16V20H4V4ZM6 6V18H14V6H6Z"
                  />
                </svg>
              </button>
              <button
                className="flex items-center gap-2 whitespace-nowrap rounded-full full px-3 py-2  dark:bg-breadgray-og-dark text-base add-token-shadow"
                onClick={watchAsset}
              >
                <BreadIcon />
                <span>Add token to wallet</span>
              </button>
              <WalletDisconnectButton handleDisconnect={handleDisconnect} />
            </div>
          </NavigationMenu.Content>
        </NavigationMenu.Item>
      </NavigationMenu.List>

      <NavigationMenu.Viewport className="absolute top-14 right-0 z-10" />
    </NavigationMenu.Root>
  );
}
