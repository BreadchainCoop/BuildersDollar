import { WriteContractReturnType } from "viem";
import { nanoid } from "nanoid";

export type TTransactionHash = WriteContractReturnType;
export type TToastType = "SUBMITTED" | "CONFIRMED" | "REVERTED";

export type TToastSubmitted = {
  id: string;
  toastType: "SUBMITTED";
  txHash: TTransactionHash;
};

export type TToastConfirmed = {
  id: string;
  toastType: "CONFIRMED";
  txHash: TTransactionHash;
};

export type TToastReverted = {
  id: string;
  toastType: "REVERTED";
  txHash: TTransactionHash;
};

export type TToast = TToastSubmitted | TToastConfirmed | TToastReverted;

export type TToastState = TToast[];

export type TToastAction =
  | {
      type: "NEW";
      payload: { toastType: TToastType; txHash: TTransactionHash };
    }
  | {
      type: "CLEAR";
      payload: { id: string };
    };

export type TToastDispatch = (action: TToastAction) => void;

export function ToastReducer(
  state: TToastState,
  action: TToastAction
): TToastState {
  switch (action.type) {
    case "NEW": {
      if (
        action.payload.toastType === "SUBMITTED" &&
        state.filter(
          (toast) =>
            toast.toastType === "SUBMITTED" &&
            toast.txHash === action.payload.txHash
        ).length > 0
      )
        return state;
      return [
        {
          id: nanoid(),
          toastType: action.payload.toastType,
          txHash: action.payload.txHash,
        },
        ...state,
      ];
    }
    case "CLEAR":
      return state.filter(
        (transaction) => transaction.id !== action.payload.id
      );
    default:
      throw new Error(`ToastContext action not recognised`);
  }
}

/*
    May want to use this function as CLEAR would fail silently if no
    tx was found with provided id
*/
function getIndex(state: TToastState, id: string): number {
  const txIndex = state.findIndex((tx) => tx.id === id);
  if (txIndex < 0) throw new Error("no tx found with that id!");
  return txIndex;
}
