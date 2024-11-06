import { ReactNode } from "react";
import { Hex } from "viem";
import Image from "next/image";

import { formatVotePercentage } from "@/app/core/util/formatter";
import { projectsMeta } from "@/app/projectsMeta";
import type { TConnectedUserState } from "@/app/core/hooks/useConnectedUser";
import { DecrementIcon, IncrementIcon } from "./Icons";
import clsx from "clsx";
import { CardBox } from "@/app/core/components/CardBox";
import { LinkIcon } from "@/app/core/components/Icons/LinkIcon";

export function ProjectRow({
  address,
  children,
}: {
  address: Hex;
  children: ReactNode;
}) {
  const {
    name,
    logoSrc,
    description,
    links: { notion },
  } = projectsMeta[address];
  return (
    <CardBox>
      {/* small */}
      <div className="sm:hidden flex flex-col sm:flex-row rounded-lg px-5 py-4 justify-start gap-4">
        <div className="m-auto flex flex-col gap-3">
          <div className="flex gap-2">
            <Image
              className="w-8 h-8"
              src={logoSrc}
              alt={`${name} logo`}
              width="56"
              height="56"
            />
            <div className="col-start-2 col-span-11 row-start-1 row-span-1 flex items-center font-bold sm:text-xl sm:font-normal text-breadgray-grey100 dark:text-breadgray-light-grey">
              {name}
            </div>
          </div>
          <div className="text-breadgray-rye">{description}</div>
        </div>
        <div className="flex items-center justify-center">{children}</div>
      </div>
      {/* large */}
      <div className="hidden sm:flex flex-col sm:flex-row rounded-lg px-5 py-4 justify-start gap-4">
        <div className="flex gap-4 grow">
          <div className="flex items-center">
            <Image
              className="min-w-14 h-14"
              src={logoSrc}
              alt={`${name} logo`}
              width="56"
              height="56"
            />
          </div>
          <div>
            <div className="col-start-2 col-span-11 row-start-1 row-span-1 flex items-center">
              <a
                className="flex gap-2 items-center font-bold sm:text-xl sm:font-normal dark:text-breadgray-ultra-white hover:text-breadpink-shaded transition-colors"
                href={notion}
                target="_blank"
                rel="noopener noreferrer"
              >
                <span>{name}</span>
                <LinkIcon />
              </a>
            </div>
            <div className="col-start-1 sm:col-start-2 sm:col-span-11 col-span-12 max-w-xs text-breadgray-rye dark:text-breadgray-grey">
              {description}
            </div>
          </div>
        </div>
        <div className="flex items-center">{children}</div>
      </div>
    </CardBox>
  );
}

export function VoteForm({
  address,
  value,
  updateValue,
  totalPoints,
  user,
  userCanVote,
}: {
  address: Hex;
  value: number;
  updateValue: (value: number, address: Hex) => void;
  totalPoints: number;
  user: TConnectedUserState;
  userCanVote: boolean;
}) {
  function increment() {
    updateValue(value + 1 <= 99 ? (value || 0) + 1 : value, address);
  }

  function decrement() {
    updateValue(value - 1 >= 0 ? (value || 0) - 1 : value, address);
  }

  const isDisabled = user.status !== "CONNECTED" || !userCanVote;

  return (
    <div className="w-full flex flex-col gap-2 sm:gap-0 sm:flex-row items-center p-4 sm:px-2 sm:py-0 border-2 border-breadgray-light-grey dark:border-breadgray-rye rounded-lg drop-shadow-[0_4px_8px_rgba(0,0,0,0.08)] bg-breadgray-ultra-white dark:bg-breadgray-burnt">
      <div className="flex items-center justify-between w-full">
        <InputButton onClick={decrement} isDisabled={isDisabled}>
          <div
            className={clsx("size-6 sm:size-5", !userCanVote && "opacity-50")}
          >
            <DecrementIcon />
          </div>
        </InputButton>
        <input
          className={clsx(
            "min-w-12 max-w-0 p-1 bg-breadgray-ultra-white dark:bg-breadgray-burnt border-neutral-300 text-4xl sm:text-2xl font-medium text-center",
            !userCanVote && "opacity-50"
          )}
          type="text"
          placeholder="00"
          inputMode="decimal"
          autoComplete="off"
          autoCorrect="off"
          pattern="^[0-9]*[.,]?[0-9]*$"
          minLength={1}
          maxLength={2}
          spellCheck="false"
          onChange={(event) => {
            updateValue(
              event.target.value ? parseInt(event.target.value) : 0,
              address
            );
          }}
          value={value === null ? "00" : value}
          disabled={isDisabled}
        />
        <InputButton onClick={increment} isDisabled={isDisabled}>
          <div
            className={clsx("size-6 sm:size-5", !userCanVote && "opacity-50")}
          >
            <IncrementIcon />
          </div>
        </InputButton>
      </div>
      <div
        className={clsx(
          "w-full text-center sm:min-w-16 sm:text-right",
          !userCanVote && "opacity-50"
        )}
      >
        {formatVotePercentage(value ? (value / totalPoints) * 100 : 0)}%
      </div>
    </div>
  );
}

function InputButton({
  onClick,
  children,
  isDisabled,
}: {
  onClick: () => void;
  children: ReactNode;
  isDisabled: boolean;
}) {
  return (
    <button className="p-2" onClick={onClick} disabled={isDisabled}>
      {children}
    </button>
  );
}

export function VoteDisplay({
  points,
  percentage,
}: {
  points: number;
  percentage: number;
}) {
  return (
    <div className="flex items-center gap-4 px-4 border-2 border-breadgray-light-grey dark:border-breadgray-rye rounded-lg dark:bg-breadgray-burnt">
      <div className="text-2xl font-medium min-w-[3rem] text-center">
        {points}
      </div>
      <div className="font-medium min-w-[4rem] text-right border-l-2 border-breadgray-light-grey dark:border-l-breadgray-rye">
        {formatVotePercentage(percentage)}%
      </div>
    </div>
  );
}
