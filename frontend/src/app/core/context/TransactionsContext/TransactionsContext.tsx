import {
  type ReactNode,
  createContext,
  useContext,
  useReducer,
  useMemo,
} from "react";
import {
  TTransactionsDispatch,
  TTransactionsState,
  TransactionsReducer,
} from "./TransactionsReducer";
import { TransactionWatcher } from "./TransactionsWatcher";

const TransactionsContext = createContext<
  | {
      transactionsState: TTransactionsState;
      transactionsDispatch: TTransactionsDispatch;
    }
  | undefined
>(undefined);

function TransactionsProvider({ children }: { children: ReactNode }) {
  const [state, dispatch] = useReducer(TransactionsReducer, {
    new: null,
    submitted: [],
  });

  const value = useMemo(
    () => ({ transactionsState: state, transactionsDispatch: dispatch }),
    [state, dispatch]
  );

  return (
    <TransactionsContext.Provider value={value}>
      {value.transactionsState.submitted.map((transaction) =>
        transaction.status === "SUBMITTED" ? (
          <TransactionWatcher
            key={`watching_transaction_${transaction.hash}`}
            transaction={transaction}
            transactionsDispatch={value.transactionsDispatch}
          />
        ) : null
      )}
      {children}
    </TransactionsContext.Provider>
  );
}

const useTransactions = () => {
  const context = useContext(TransactionsContext);
  if (context === undefined) {
    throw new Error(
      "useTransactions must be used within a TransactionsProvider"
    );
  }
  return context;
};

export { TransactionsProvider, useTransactions };
