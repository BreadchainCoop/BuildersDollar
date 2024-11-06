import { DEV_ACCOUNT, anvilAccounts, testClient } from "./lib";
import { bakeBread, balanceOf } from "./lib";

/**
 *
 * Bakes BREAD for test wallets
 *
 */

export async function main() {
  await bakeBread(DEV_ACCOUNT);

  await balanceOf(DEV_ACCOUNT);
}

main();
