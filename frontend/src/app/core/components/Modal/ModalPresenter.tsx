import * as Dialog from "@radix-ui/react-dialog";
import { AnimatePresence, motion } from "framer-motion";
import { useModal } from "@/app/core/context/ModalContext";
import { ConfirmRecastModal } from "./ConfirmRecastModal";
import { ModalOverlay } from "./ModalUI";
import { VoteTransactionModal } from "./TransactionModal/VoteTransactionModal";
import { BakeryTransactionModal } from "./TransactionModal/BakeryTransactionModal";

export function ModalPresenter() {
  const { modalState, setModal } = useModal();

  return (
    <Dialog.Root open={!!modalState} onOpenChange={() => setModal(null)}>
      <Dialog.Portal forceMount>
        <AnimatePresence mode="wait">
          {modalState && (
            <>
              <Dialog.Overlay forceMount asChild>
                <ModalOverlay />
              </Dialog.Overlay>
              <Dialog.Content forceMount>
                {(() => {
                  switch (modalState.type) {
                    case "BAKERY_TRANSACTION":
                      return <BakeryTransactionModal modalState={modalState} />;
                    case "VOTE_TRANSACTION":
                      return <VoteTransactionModal modalState={modalState} />;
                    case "CONFIRM_RECAST":
                      return <ConfirmRecastModal setModal={setModal} />;
                    default:
                      throw new Error(
                        "unhandled modalState.type in switch statement"
                      );
                  }
                })()}
              </Dialog.Content>
            </>
          )}
        </AnimatePresence>
      </Dialog.Portal>
    </Dialog.Root>
  );
}
