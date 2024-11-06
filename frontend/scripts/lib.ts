import { BREAD_ABI, DISTRIBUTOR_ABI, ERC20_ABI } from "../src/abi";
import { getConfig } from "../src/chainConfig";
import {
  Hex,
  createPublicClient,
  createTestClient,
  http,
  parseEther,
  parseUnits,
  walletActions,
} from "viem";
import { foundry } from "viem/chains";

const config = getConfig(31337);

export const anvilAccounts: Array<Hex> = [
  // mock wallet 2
  // "0x70997970c51812dc3a010c7d01b50e0d17dc79c8",
  "0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc",
  "0x90f79bf6eb2c4f870365e785982e1f101e93b906",
  "0x15d34aaf54267db7d7c367839aaf71a00a2c6a65",
  "0x9965507d1a55bcc2695c58ba16fb37d819b0a4dc",
  "0x976ea74026e726554db657fa54763abd0c3a0aa9",
  "0x14dc79964da2c08b23698b3d3cc7ca32193d9955",
  "0x23618e81e3f5cdf7f54c3d65f7fbc0abf5b21e8f",
  "0xa0ee7a142d267c1f36714e4a8f75612f20a79720",
];

export const DEV_ACCOUNT = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
const LP_TOKEN_WHALE = "0xc2fB4B3EA53E10c88D193E709A81C4dc7aEC902e" as Hex;
const LP_TOKEN_CONTRACT = "0xf3d8f3de71657d342db60dd714c8a2ae37eac6b4" as Hex;

// test client is useful as you can use it to send transactions
// with any wallet without having the private key
// https://viem.sh/docs/clients/test.html
export const testClient = createTestClient({
  chain: foundry,
  mode: "anvil",
  transport: http(),
}).extend(walletActions);

export const publicClient = createPublicClient({
  chain: foundry,
  transport: http(),
});

// bake bread with provided account
export async function bakeBread(
  account: Hex = DEV_ACCOUNT,
  value: number = 5000
) {
  await testClient.impersonateAccount({
    address: account,
  });

  try {
    const hash = await testClient.writeContract({
      account: account,
      address: config.BREAD.address,
      abi: BREAD_ABI,
      functionName: "mint",
      // mint is a payable function so we pass the value like this
      value: parseEther(value.toString()),
      args: [account],
    });

    // get the hash then wait for the tx to complete
    const transaction = await publicClient.waitForTransactionReceipt({ hash });

    console.log(`Bread baked by ${account} - ${transaction.status}`);
  } catch (err) {
    console.log(err);
  }
}

// funds provided account with LP tokens
export async function fundLpTokens(account: Hex = DEV_ACCOUNT) {
  await testClient.impersonateAccount({
    address: account,
  });

  // sending the account with LP tokens some xdai first
  // so it can pay the gas fees to send the LP tokens
  await testClient.sendTransaction({
    account: account,
    to: LP_TOKEN_WHALE,
    value: parseUnits("5", 18),
  });

  // impersonate the account with the LP tokens
  await testClient.impersonateAccount({
    address: LP_TOKEN_WHALE,
  });

  await testClient.writeContract({
    account: LP_TOKEN_WHALE,
    address: LP_TOKEN_CONTRACT,
    abi: ERC20_ABI,
    functionName: "transfer",
    // this isn't a payable function so we pass the value as an argument
    args: [DEV_ACCOUNT, parseUnits("1000", 18)],
  });
}

export async function balanceOf(anvilAccount: Hex) {
  await testClient.impersonateAccount({
    address: anvilAccount,
  });

  const res = await publicClient.readContract({
    address: config.BREAD.address,
    abi: BREAD_ABI,
    functionName: "balanceOf",
    args: [anvilAccount],
  });

  console.log(`Bread balance of ${anvilAccount} - ${res}`);
}

function generateVote() {
  const vote = Math.floor(Math.random() * 10) + 1;
  console.log(`Vote: ${vote}`);
  return vote;
}

export async function submitVote(anvilAccount: Hex) {
  await testClient.impersonateAccount({
    address: anvilAccount,
  });

  try {
    const hash = await testClient.writeContract({
      address: config.DISBURSER.address,
      abi: DISTRIBUTOR_ABI,
      functionName: "castVote",
      account: anvilAccount,
      args: [
        [
          generateVote(),
          generateVote(),
          generateVote(),
          generateVote(),
          generateVote(),
        ],
      ],
    });

    const receipt = await publicClient.waitForTransactionReceipt({ hash });

    if (receipt.status !== "success") {
      console.log(`Failed to vote: ${anvilAccount} - `, Object.keys(receipt));
      // console.log({ receipt });

      const transaction = await publicClient.getTransaction({ hash });

      console.log({ transaction });

      // const callData = {
      //   to: receipt.to,
      //   data: transaction.input,
      //   from: receipt.from,
      //   gas: receipt.gasUsed,
      // };

      await publicClient
        .call({ data: transaction.input, blockNumber: receipt.blockNumber })
        .catch((error) => {
          const revertReason = error.data;
          console.log("Revert error:", error);
          console.log("Revert reason:", revertReason);
        });

      return;
    }

    console.log(`Mock Bread Holder voted: ${anvilAccount} - ${receipt.status}`);
  } catch (err) {
    console.log(err);
  }
}

export async function getCurrentDistribution() {
  const res = await publicClient.readContract({
    address: config.DISBURSER.address,
    abi: DISTRIBUTOR_ABI,
    functionName: "getCurrentVotingDistribution",
  });

  console.log(`Current distribution: - ${res}`);
}
