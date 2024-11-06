import {
  createContext,
  ReactNode,
  useContext,
  useMemo,
  useReducer,
} from "react";

export type TSwapState = {
  mode: "BAKE" | "BURN";
  value: string;
  isContractApproved: null | boolean;
} | null;

const initialSwapState: TSwapState = {
  mode: "BAKE",
  value: "",
  isContractApproved: null,
};

export type TSwapAction =
  | {
      type: "REVERSE";
    }
  | {
      type: "RESET";
    }
  | {
      type: "SET_INPUT_VALUE";
      payload: {
        value: string;
      };
    };

/* eslint-disable-next-line no-unused-vars */
export type TSwapDispatch = (action: TSwapAction) => void;

export const DispatchContext = createContext({});
const SwapContext = createContext<{ state: TSwapState }>({
  state: initialSwapState,
});

const reducer = (state: TSwapState, action: TSwapAction) => {
  /*
    
    const resetSwapState = () => {
    setSwapState(initialSwapState);
  };

  const clearInputValue = () => {
    setSwapState((state) => ({ ...state, value: "" }));
  };

  const handleInputChange = (event: ChangeEvent<HTMLInputElement>) => {
    if (transactionDisplay && transactionDisplay.status !== "PENDING") {
      dispatchTransactionDisplay({ type: "CLEAR" });
    }
    const { value } = event.target;

    const sanitizedValue = sanitizeInputValue(value);
    setSwapState({
      ...swapState,
      value: sanitizedValue,
    });
  };

  const handleSwapReverse = () => {
    setSwapState((state) => ({
      ...state,
      mode: state.mode === "BAKE" ? "BURN" : "BAKE",
    }));
  };

  const handleBalanceClick = (value: string) => {
    setSwapState((state) => ({
      ...state,
      value,
    }));
  };
    
    
    */
  const { type: actionType } = action;
  switch (actionType) {
    case "RESET":
      // do stuff
      return state;

    case "SET_INPUT_VALUE":
      // do stuff
      return state;
    case "REVERSE":
      // do stuff
      return state;
    default:
      return state;
  }
};

interface ISwapProviderProps {
  children: ReactNode;
}

function SwapProvider({ children }: ISwapProviderProps) {
  const [state, dispatch] = useReducer(reducer, null);

  const stateMemo = useMemo(() => ({ state }), [state]);
  const dispatchMemo = useMemo(() => ({ dispatch }), [dispatch]);

  return (
    <DispatchContext.Provider value={dispatchMemo}>
      <SwapContext.Provider value={stateMemo}>{children}</SwapContext.Provider>
    </DispatchContext.Provider>
  );
}

const useSwap = () => {
  const context = useContext(SwapContext);
  if (context === undefined) {
    throw new Error("useSwap must be used within a SwapProvider");
  }
  return context;
};

export { SwapProvider, useSwap };
