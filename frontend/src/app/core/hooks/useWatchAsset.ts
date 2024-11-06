import { createWalletClient, custom } from "viem";
import { mainnet } from "viem/chains";

import { useEffect, useState } from "react";

export function useWatchAsset() {
  const [isComplete, setIsComplete] = useState(true);

  function watchAsset() {
    setIsComplete(false);
  }

  useEffect(() => {
    (async () => {
      if (isComplete) return;
      const { ethereum } = window as any;
      const walletClient = createWalletClient({
        chain: mainnet,
        transport: custom(ethereum),
      });
      try {
        await walletClient.watchAsset({
          type: "ERC20",
          options: {
            address: "0xa555d5344f6FB6c65da19e403Cb4c1eC4a1a5Ee3",
            decimals: 18,
            symbol: "BREAD",
          },
        });
      } catch (err) {
        console.error(err);
      }
      setIsComplete(true);
    })();
  }, [isComplete, setIsComplete]);

  return { watchAsset };
}
