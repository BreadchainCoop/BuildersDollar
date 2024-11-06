import { ReactNode } from "react";

export function CardBox({ children }: { children: ReactNode }) {
  return (
    <div className="rounded-lg bg-breadgray-ultra-white dark:bg-breadgray-charcoal border border-1 border-breadgray-light-grey dark:border-breadgray-toast">
      {children}
    </div>
  );
}
