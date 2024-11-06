import {
  type ReactNode,
  createContext,
  useContext,
  useMemo,
  useReducer,
} from "react";
import {
  TToastDispatch,
  TToastState,
  ToastReducer,
} from "./ToastContextReducer";

const ToastContext = createContext<
  | {
      toastState: TToastState;
      toastDispatch: TToastDispatch;
    }
  | undefined
>(undefined);

function ToastProvider({ children }: { children: ReactNode }) {
  const [state, dispatch] = useReducer(ToastReducer, []);

  const value = useMemo(
    () => ({ toastState: state, toastDispatch: dispatch }),
    [state, dispatch]
  );

  return (
    <ToastContext.Provider value={value}>{children}</ToastContext.Provider>
  );
}

const useToast = () => {
  const context = useContext(ToastContext);
  if (context === undefined) {
    throw new Error("useToast must be used within a ToastProvider");
  }
  return context;
};

export { ToastProvider, useToast };
