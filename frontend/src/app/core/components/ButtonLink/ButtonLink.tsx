import { forwardRef, Ref, type ReactNode } from "react";
import {
  TButtonSize,
  TButtonVariant,
  ButtonVariants,
  ButtonSizes,
} from "@/app/core/components/Button/Button";
import clsx from "clsx";

interface IProps {
  children: ReactNode;
  size?: TButtonSize;
  href: string;
  additionalClasses: string;
  variant?: TButtonVariant;
  fullWidth?: boolean;
}

const ButtonLink = forwardRef(
  (
    {
      children,
      href = "/",
      additionalClasses = "",
      size = "regular",
      variant = "primary",
      fullWidth = false,
    }: IProps,
    ref: Ref<HTMLButtonElement>
  ) => {
    return (
      <a
        href={href}
        className={clsx(
          "rounded-xl inline-block font-bold transition-all",
          additionalClasses,
          ButtonSizes[size],
          ButtonVariants[variant],
          fullWidth && "w-full"
        )}
      >
        {children}
      </a>
    );
  }
);

ButtonLink.displayName = "ButtonLink";

export default ButtonLink;
