type TProps = {
  onClick: () => void;
};

function SwapReverse({ onClick }: TProps) {
  return (
    <button
      type="button"
      aria-label="switch between bake and burn"
      className="absolute top-1/2 left-1/2 transform -translate-y-1/2 -translate-x-1/2  inline-block bg-breadgray-ultra-white  dark:bg-breadgray-grey300 px-5 py-2 dark:text-breadgray-ultra-white border-2 rounded-lg border-breadgray-rye dark:border-breadgray-grey200 hover:border-breadviolet-shaded dark:hover:border-breadpink-shaded transition-all group"
      onClick={onClick}
    >
      <div className="h-4 w-4 group-hover:transform group-hover:scale-125 group-hover:transition-transform">
        <DownIcon />
      </div>
    </button>
  );
}

function DownIcon() {
  return (
    <svg
      className="w-full h-full"
      viewBox="0 0 15 16"
      xmlns="http://www.w3.org/2000/svg"
    >
      <path
        className="fill-current"
        fillRule="evenodd"
        clipRule="evenodd"
        d="M6.5 0H8.5V12H10.5V14H8.5V16H6.5V14H4.5V12H6.5V0ZM2.5 10V12H4.5V10H2.5ZM2.5 10V8H0.5V10H2.5ZM12.5 10V12H10.5V10H12.5ZM12.5 10V8H14.5V10H12.5Z"
      />
    </svg>
  );
}

export default SwapReverse;
