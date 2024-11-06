import {
  ModalAdviceText,
  ModalContainer,
  ModalContent,
  ModalHeading,
  transactionIcons,
  TransactionStatusCheck,
  TransactionStatusCross,
  TransactionStatusSpinner,
} from "../ModalUI";
import { TTransactionStatus } from "../../../context/TransactionsContext/TransactionsReducer";

import { ExplorerLink } from "../../ExplorerLink";
import { useTransactions } from "@/app/core/context/TransactionsContext/TransactionsContext";
import { VoteModalState } from "@/app/core/context/ModalContext";

const modalAdviceText: {
  [key in TTransactionStatus]: string;
} & { PREPARED: string } = {
  PREPARED: "Please confirm transaction in your wallet",
  SUBMITTED: "Waiting for on-chain confimation",
  SAFE_SUBMITTED: "Safe Transaction Submitted",
  CONFIRMED: "Transaction Confirmed",
  REVERTED: "Transaction Reverted",
};

export function VoteTransactionModal({
  modalState,
}: {
  modalState: VoteModalState;
}) {
  const { transactionsState } = useTransactions();

  const transaction = transactionsState.new
    ? {
        status: "PREPARED",
        hash: null,
      }
    : transactionsState.submitted.find(
        (transaction) => transaction.hash === modalState.hash
      );

  if (!transaction)
    throw new Error("Transaction modal requires a transaction!");

  const txStatus = transaction.status as TTransactionStatus;

  return (
    <ModalContainer>
      <ModalHeading>Casting Vote</ModalHeading>
      <ModalContent>
        {transactionIcons[txStatus]}
        {transaction.status === "PREPARED" ? (
          <ModalAdviceText>
            {modalAdviceText[transaction.status]}
          </ModalAdviceText>
        ) : (
          <>
            <ModalAdviceText>{modalAdviceText[txStatus]}</ModalAdviceText>
            {transaction.hash && (
              <ExplorerLink
                to={`https://gnosisscan.io/tx/${transaction.hash}`}
              />
            )}
          </>
        )}
      </ModalContent>
    </ModalContainer>
  );
}
