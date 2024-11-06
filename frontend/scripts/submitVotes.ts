import { anvilAccounts, getCurrentDistribution } from "./lib";
import { submitVote } from "./lib";

async function main() {
  // for (let i = 0; i < 15 * 24; i++) {
  //   await testClient.mine({ blocks: 535680 / 31 / 24 });
  //   await testClient.increaseTime({ seconds: 60 * 60 });
  // }

  for (let i = 0; i < anvilAccounts.length; i++) {
    await submitVote(anvilAccounts[i]);
  }

  await getCurrentDistribution();
}

main();
