// import config from "@/config";
// import Elipsis from "@/app/core/components/Elipsis";
// import { useToast } from "@/app/core/hooks/useToast";
// import {
//   useTransactionDisplay,
//   type TTransactionStatus,
// } from "@/app/core/hooks/useTransactionDisplay";
// import { useEffect } from "react";
// import { useWaitForTransaction } from "wagmi";
// import { TUserConnected } from "@/app/core/hooks/useConnectedUser";

// interface IProps {
//   hash: `0x${string}`;
//   status: TTransactionStatus;
//   user: TUserConnected;
// }

// function Transaction({ hash, status, user }: IProps) {
//   const { dispatch: dispatchTransactionDisplay } = useTransactionDisplay();
//   const { dispatch: dispatchToast } = useToast();

//   const { data: transactionData, isError: transactionIsError } =
//     useWaitForTransaction({ chainId: user.config.ID, hash });

//   useEffect(() => {
//     if (transactionIsError) {
//       dispatchToast({
//         type: "SET_TOAST",
//         payload: {
//           type: "ERROR",
//           message: "transaction failed",
//         },
//       });
//     }
//     if (transactionData?.status === "success") {
//       dispatchTransactionDisplay({ type: "SET_COMPLETE" });
//     }
//   }, [
//     transactionData,
//     transactionIsError,
//     dispatchTransactionDisplay,
//     dispatchToast,
//   ]);

//   return (
//     <div className="mt-8 w-full text-xs">
//       <div>
//         <a
//           className="break-all text-neutral-400 underline"
//           target="_blank"
//           rel="noopener noreferrer"
//           href={`${user.config.EXPLORER}/tx/${hash}`}
//         >
//           {hash}
//         </a>
//       </div>
//       <div className="mt-4 text-neutral-300">
//         {status === "PENDING" && (
//           <>
//             transaction pending
//             <Elipsis />
//           </>
//         )}
//         {status === "COMPLETE" && "transaction complete!"}
//       </div>
//     </div>
//   );
// }

// export default Transaction;
