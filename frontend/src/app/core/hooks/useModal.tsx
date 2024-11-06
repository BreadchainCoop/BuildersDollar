// import * as DialogPrimitive from "@radix-ui/react-dialog";
// import {
//   ReactNode,
//   createContext,
//   useCallback,
//   useContext,
//   useEffect,
//   useMemo,
//   useReducer,
//   useState,
// } from "react";
// import { TTransactionDisplayState } from "./useTransactionDisplay";

// export type TModalType =
//   | "DISCLAIMER"
//   | "CONNECT_WALLET"
//   | "CHANGE_NETWORK"
//   | "CHANGING_NETWORK"
//   | "APPROVAL"
//   | "BAKING"
//   | "BURNING"
//   | "CLAIMING"
//   | "CONNECTORS"
//   | "CONNECTORS"
//   | "SAFE_TRANSACTION";

// export type TModalStatus = "LOCKED" | "UNLOCKED";

// export interface IBaseModalState {
//   type: TModalType;
//   status: TModalStatus;
// }
// export interface IBakeModalState extends IBaseModalState {
//   amount: string;
// }

// export interface IBurnModalState extends IBaseModalState {
//   amount: string;
// }

// export type TModalState =
//   | null
//   | IBaseModalState
//   | IBakeModalState
//   | IBurnModalState;

// export type TModalAction =
//   | {
//       type: "SET_MODAL";
//       payload: {
//         type: TModalType;
//       };
//     }
//   | {
//       type: "UNLOCK_MODAL";
//     }
//   | {
//       type: "CLEAR_MODAL";
//     };

// /* eslint-disable-next-line no-unused-vars */
// export type TModalDispatch = (action: TModalAction) => void;

// const ModalContext = createContext<
//   | {
//       state: TModalState;
//       dispatch: TModalDispatch;
//     }
//   | undefined
// >(undefined);

// const modalReducer = (
//   state: TModalState,
//   action: TModalAction
// ): TModalState => {
//   const { type: actionType } = action;
//   switch (actionType) {
//     case "SET_MODAL":
//       /* eslint-disable-next-line no-case-declarations */
//       const {
//         payload: { type },
//       } = action;
//       return {
//         type,
//         status: "LOCKED",
//       };
//     case "UNLOCK_MODAL":
//       if (state === null) throw new Error("modal not set");
//       if (
//         state.type !== "BAKING" &&
//         state.type !== "BURNING" &&
//         state.type !== "CLAIMING"
//       )
//         throw new Error("modal type cannot be unlocked");
//       return {
//         ...state,
//         status: "UNLOCKED",
//       };
//     case "CLEAR_MODAL":
//       return null;
//     default:
//       return state;
//   }
// };

// function ModalProvider({
//   children,
//   initialState = null,
// }: {
//   children: ReactNode;
//   initialState?: TModalState;
// }) {
//   const [state, dispatch] = useReducer(modalReducer, initialState);
//   const [isOpen, setIsOpen] = useState(false);

//   const value = useMemo(() => ({ state, dispatch }), [state, dispatch]);

//   const onOpenChange = useCallback(
//     (open: boolean) => {
//       setIsOpen(open);
//     },
//     [setIsOpen]
//   );

//   useEffect(() => {
//     if (state === null) {
//       onOpenChange(false);
//     } else {
//       onOpenChange(true);
//     }
//   }, [state, onOpenChange]);

//   return (
//     <ModalContext.Provider value={value}>
//       {/* <DialogPrimitive.Root open={!!state} onOpenChange={onOpenChange}> */}
//       {children}
//       {/* </DialogPrimitive.Root> */}
//     </ModalContext.Provider>
//   );
// }

// const useModal = () => {
//   const context = useContext(ModalContext);
//   if (context === undefined) {
//     throw new Error("useModal must be used within a ModalProvider");
//   }
//   return context;
// };

// export { ModalProvider, useModal };
