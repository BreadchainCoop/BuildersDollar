import { createPublicClient, http } from "viem";
import { foundry } from "viem/chains";

export const viemClient = createPublicClient({
  chain: foundry,
  transport: http("http://localhost:8545"),
});
