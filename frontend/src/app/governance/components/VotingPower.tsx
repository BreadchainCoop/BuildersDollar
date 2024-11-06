import clsx from "clsx";

import { CheckIcon } from "@/app/core/components/Icons/CheckIcon";
import { formatBalance, formatDate } from "@/app/core/util/formatter";
import { TConnectedUserState } from "@/app/core/hooks/useConnectedUser";
import { CycleDatesState } from "../useCycleDates";
import { CycleLengthSuccess } from "../useCycleLength";

export function VotingPower({
  minRequiredVotingPower,
  userVotingPower,
  userHasVoted,
  userCanVote,
  cycleDates,
  cycleLength,
  user,
  distributeEqually,
  isRecasting,
}: {
  minRequiredVotingPower: number | null;
  userVotingPower: number | null;
  userHasVoted: boolean;
  userCanVote: boolean;
  cycleDates: CycleDatesState;
  cycleLength: CycleLengthSuccess;
  user: TConnectedUserState;
  distributeEqually: () => void;
  isRecasting: boolean;
}) {
  const days = (cycleLength.data * 5) / 60 / 60 / 24;
  return (
    <section className="sm:pt-8 sm:pb-4 flex flex-col sm:flex-row">
      <div className="grow">
        <div className="flex gap-2 items-center">
          <span className="size-6 flex">
            <svg
              className="w-full h-full"
              viewBox="0 0 24 24"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
            >
              <circle
                cx="12"
                cy="12"
                r="12"
                className="fill-white dark:fill-breadgray-charcoal"
              />
              <g filter="url(#filter0_d_5871_31200)">
                <path
                  fillRule="evenodd"
                  clipRule="evenodd"
                  d="M9.99902 5.00012H8.99805V7.00012V9.00012V11.0001H9.99902V11.0001H11.999V9.00014H10.998V9.00012V9.00009H11.999V7.00012V7.00009V5.00012H10.998H9.99902ZM4.99902 7.00009H5.99756H6.99902H7.99756V9.00009H6.99902H5.99756H4.99902V7.00009ZM7.99756 9.00014H6.99902H5.99805V9.00012H3.99805V11.0001H4.99902V11.0001H5.99756H6.99902H7.99756V9.00014ZM6.99854 12.0001H4.99902V14.0001H6.99854V14.0001H5.99756V16.0001H7.99707V17.0001V17.0001V18.0001V18.0002V19.0001V20.0002H9.99707V19.0001V18.0002V18.0001V17.0001V17.0001V16.0001H9.99902V17.0001V18.0001V18.0002V19.0001V20.0002H11.9985H11.999H12.9971H13.9985H14.9971V19.0001V18.0002V17.0001H15.998V16.0001H16.999V15.0002H17.9976V13.0002H15.998V13.0001H16.9985H16.999H18.9985V11.0001V11.0001V9.00014H16.999H16.9985H14.999V11.0001V11.0001V12.0001H13.998V13.0002H12.9971V14.0001H11.9985V16.0001H10.998V14.0001V14.0001H11.999V12.0001H9.99902V12.0001H8.99854V12.0001H6.99902H6.99854ZM3.99805 12.0001H4.99805V13.0001H3.99805V12.0001ZM14.9971 14.0001V15.0001H14.999V14.0001H15.9976V14.0001H14.9971ZM12.9971 9.00014H14.9971V11.0001H12.9971V9.00014ZM12.9971 5.00012H13.998H14.9971H15.998V6.00012V7.00012V8.00012H13.998V8.00011H12.9971V7.00012V6.00011V5.00012Z"
                  fill="url(#paint0_linear_5871_31200)"
                />
              </g>
              <defs>
                <filter
                  id="filter0_d_5871_31200"
                  x="1.99805"
                  y="4.00012"
                  width="19"
                  height="19"
                  filterUnits="userSpaceOnUse"
                  colorInterpolationFilters="sRGB"
                >
                  <feFlood floodOpacity="0" result="BackgroundImageFix" />
                  <feColorMatrix
                    in="SourceAlpha"
                    type="matrix"
                    values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 127 0"
                    result="hardAlpha"
                  />
                  <feOffset dy="1" />
                  <feGaussianBlur stdDeviation="1" />
                  <feComposite in2="hardAlpha" operator="out" />
                  <feColorMatrix
                    type="matrix"
                    values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.08 0"
                  />
                  <feBlend
                    mode="normal"
                    in2="BackgroundImageFix"
                    result="effect1_dropShadow_5871_31200"
                  />
                  <feBlend
                    mode="normal"
                    in="SourceGraphic"
                    in2="effect1_dropShadow_5871_31200"
                    result="shape"
                  />
                </filter>
                <linearGradient
                  id="paint0_linear_5871_31200"
                  x1="6.06061"
                  y1="16.8126"
                  x2="16.7482"
                  y2="7.81231"
                  gradientUnits="userSpaceOnUse"
                >
                  <stop stopColor="#D04EC5" />
                  <stop offset="1" stopColor="#ED7BC7" />
                </linearGradient>
              </defs>
            </svg>
          </span>
          <span className="font-bold text-2xl leading-none text-breadgray-grey100 dark:text-breadgray-ultra-white">
            Voting Power:{" "}
          </span>
          <span className="font-medium text-xl">
            {user.status === "CONNECTED" &&
              userVotingPower &&
              formatBalance(userVotingPower / cycleLength.data, 2)}
          </span>
        </div>
        <p className="max-w-96 text-breadgray-rye dark:text-breadgray-light-grey pt-2">
          {`Your Voting Power is equal to the average amount of BREAD you held during the ${Math.round(
            days
          )} days up until the current round of voting opened.`}
        </p>
      </div>
      <div className="pt-6 sm:p-0">
        {userHasVoted && !isRecasting ? (
          <UserHasVoted cycleDates={cycleDates} />
        ) : !userCanVote &&
          minRequiredVotingPower !== null &&
          userVotingPower !== null &&
          userVotingPower < minRequiredVotingPower ? (
          <NotEnoughPower />
        ) : user.status === "CONNECTED" ? (
          <DistributeEqually distributeEqually={distributeEqually} />
        ) : null}
      </div>
    </section>
  );
}
const widgetBaseClasses =
  "py-3 sm:py-2 px-4 sm:w-[215px] flex flex-col items-center justify-center rounded-xl border-2";

function NotEnoughPower() {
  return (
    <div className={clsx(widgetBaseClasses, "border-status-danger")}>
      <span className="dark:text-breadgray-ultra-white font-bold text-xl">
        No Power
      </span>
      <a
        className="font-bold text-breadpink-shaded"
        href="https://breadchain.notion.site/BREAD-Voting-Power-UI-0f2d350320b94e4ba9aeec2ef6fdcb84"
        target="_blank"
        rel="noopener noreferrer"
      >
        Learn why
      </a>
    </div>
  );
}

function UserHasVoted({ cycleDates }: { cycleDates: CycleDatesState }) {
  return (
    <div className={clsx(widgetBaseClasses, "border-status-success")}>
      <div className="flex gap-4">
        <div className="w-7 h-7 flex items-center text-status-success">
          <CheckIcon />
        </div>
        <span className="dark:text-breadgray-ultra-white font-bold text-xl">
          Voted
        </span>
      </div>
      <div>
        <span className="dark:text-breadgray-grey">Next round: </span>
        {(() => {
          switch (cycleDates.status) {
            case "LOADING":
              return <span>--/--/--</span>;
            case "SUCCESS":
              return <span>{formatDate(cycleDates.end)}</span>;
            case "ERROR":
            default:
              throw new Error("Invalid status!");
          }
        })()}
      </div>
    </div>
  );
}

function DistributeEqually({
  distributeEqually,
}: {
  distributeEqually: () => void;
}) {
  return (
    <button
      className="dis-equally-button-bg text-white dark:text-breadgray-grey100 dark:hover:text-white rounded-xl p-2.5 flex items-center gap-3 border-2 border-breadgray-light-grey hover:border-breadgray-grey dark:border-breadgray-grey100 dark:hover:border-breadgray-ultra-white transform transition-all drop-shadow-[0_4px_10px_rgba(0,0,0,0.10)]"
      onClick={distributeEqually}
    >
      <div className="w-5 h-5 flex items-center">
        <svg
          className="fill-current"
          viewBox="0 0 22 20"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path
            fillRule="evenodd"
            clipRule="evenodd"
            d="M8 0H4V2H2V4H0V10H2V12H4V14H6V16H8V18H10V20H12V18H14V16H16V14H18V12H20V10H22V4H20V2H18V0H14V2H12V4H10V2H8V0ZM8 2V4H10V6H12V4H14V2H18V4H20V10H18V12H16V14H14V16H12V18H10V16H8V14H6V12H4V10H2V4H4V2H8Z"
          />
        </svg>
      </div>

      <span className="text-lg font-bold">Distribute Equally</span>
    </button>
  );
}
