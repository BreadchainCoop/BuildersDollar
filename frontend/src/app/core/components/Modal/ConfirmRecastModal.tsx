import { ModalContainer, ModalContent, ModalHeading } from "./ModalUI";
import { ModalState } from "../../context/ModalContext";
import Button from "../Button";

export function ConfirmRecastModal({
  setModal,
}: {
  setModal: (modalState: ModalState) => void;
}) {
  return (
    <ModalContainer>
      <ModalHeading>Re-cast your vote?</ModalHeading>
      <ModalContent>
        <div className="size-12 text-status-warning">
          <svg
            className="fill-current w-full h-full"
            viewBox="0 0 65 64"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              fillRule="evenodd"
              clipRule="evenodd"
              d="M8.5 8H13.8333H51.1667H56.5V56L51.1667 56L13.8333 56H8.5V8ZM51.1667 50.6667V13.3333H13.8333V50.6667H51.1667ZM29.8333 40H35.1667V45.3333H29.8333V40ZM35.1667 18.6667H29.8333V34.6667H35.1667V18.6667Z"
            />
          </svg>
        </div>
        <p className="text-center text-breadgray-rye dark:text-breadgray-light-grey">
          You are about to Re-cast your vote. Your previous votes of this cycle
          will be removed.
        </p>
        <Button
          variant="primary"
          size="large"
          fullWidth
          onClick={() =>
            setModal({ type: "CONFIRM_RECAST", isConfirmed: true })
          }
        >
          Yes, proceed
        </Button>
        <Button
          variant="secondary"
          size="large"
          fullWidth
          onClick={() => {
            setModal(null);
          }}
        >
          Cancel
        </Button>
      </ModalContent>
    </ModalContainer>
  );
}
