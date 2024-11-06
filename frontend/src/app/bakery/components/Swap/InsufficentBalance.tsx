import { ButtonSizes } from "@/app/core/components/Button/Button";
import clsx from "clsx";

export function InsufficentBalance() {
  return (
    <div
      className={clsx(
        ButtonSizes["large"],
        "flex justify-center items-center gap-4 w-full text-status-danger-light dark:text-status-danger rounded-xl font-bold text-center border-2 border-status-danger-light dark:border-status-danger"
      )}
    >
      <svg
        className="fill-current"
        width="25"
        height="24"
        viewBox="0 0 25 24"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
      >
        <path
          fillRule="evenodd"
          clipRule="evenodd"
          d="M3.5 3H5.49976H5.5H19.4998V5H5.5V19H19.4998V21L5.5 21L5.49976 21L3.5 21V3ZM21.5 3H19.5V21H21.5V3ZM11.5 15.0001H13.5V17.0001H11.5V15.0001ZM13.5 7H11.5V13H13.5V7Z"
        />
      </svg>
      Insufficient Funds
    </div>
  );
}
