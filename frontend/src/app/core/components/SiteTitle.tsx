import type { ReactNode } from "react";

export function Title({ children }: { children: ReactNode }) {
  return (
    <div className="flex flex-col py-16 text-center text-neutral-200 sm:py-32">
      {children}
    </div>
  );
}

export function H1({ children }: { children: ReactNode }) {
  return <h1 className="mb-1 text-[32rem]] md:mb-2 font-bold">{children}</h1>;
}

export function H2({ children }: { children: ReactNode }) {
  return <h2 className="text-1xl sm:text-2xl font-bold">{children}</h2>;
}
function SiteTitle() {
  return (
    <Title>
      <H1>BREADCHAIN</H1>
      <p>wuurrr</p>
      <H2>CROWDSTAKING</H2>
    </Title>
  );
}

export default SiteTitle;
