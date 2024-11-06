export function LiquidityBanner() {
  return (
    <div className="w-full max-w-[30rem] m-auto rounded-xl flex flex-col items-start md:flex-row md:items-center gap-4 p-4 bg-breadgray-ultra-white dark:bg-black relative overflow-hidden">
      <div className="grow grid grid-cols-1 gap-2 z-30">
        <span className="text-breadgray-grey300 dark:text-white text-2xl font-medium">
          Grow the pool
        </span>
        <span>Earn while supporting $BREAD</span>
      </div>
      <a
        href="https://curve.fi/#/xdai/pools/factory-stable-ng-15/deposit"
        target="_blank"
        rel="noopener noreferrer"
        className="w-full md:w-auto px-4 py-2 rounded-xl text-center text-breadgray-charcoal dark:text-breadpink-shaded font-bold border-2 border-[#F7DDF2] dark:border-none z-30 backdrop-blur-md dark:bg-[#ED7BC7] dark:bg-opacity-20 hover:bg-breadviolet-shaded hover:text-breadgray-ultra-white transition-colors"
      >
        Add liquidity
      </a>
      <div className="absolute w-full h-full left-0 top-0 bg-white dark:bg-black opacity-70 z-20" />
      <WaveOne />
      <WaveTwo />
    </div>
  );
}

function WaveOne() {
  return (
    <svg
      className="absolute bottom-0 left-0 z-10"
      width="500"
      height="77"
      viewBox="0 0 500 77"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <path
        d="M76.7326 15.2442C30.1718 10.2139 -1.82279 32.9102 -12 44.8872V194H1762.65V19.7356C1757.88 39.797 1739.37 81.1773 1703.5 86.2076C1658.65 92.4955 1630.03 19.7356 1588.05 19.7356C1546.07 19.7356 1551.79 63.7508 1497.41 86.2076C1443.02 108.664 1406.77 37.701 1356.2 19.7356C1305.63 1.77022 1315.17 63.7508 1251.25 86.2076C1187.32 108.664 1188.27 31.4131 1126.26 19.7356C1064.24 8.05811 1090.96 71.8353 1015.58 79.9197C940.205 88.0041 948.792 28.7183 882.958 15.2442C817.125 1.77017 822.849 44.8872 769.419 63.7508C715.989 82.6145 692.136 23.3287 613.898 3.56677C535.661 -16.1952 563.33 52.0733 474.598 63.7508C385.865 75.4284 386.819 26.0235 320.031 15.2442C253.244 4.46498 235.115 63.7508 176.914 63.7508C118.714 63.7508 134.933 21.5321 76.7326 15.2442Z"
        fill="url(#paint0_linear_2879_9360)"
      />
      <defs>
        <linearGradient
          id="paint0_linear_2879_9360"
          x1="232.015"
          y1="152.775"
          x2="267.829"
          y2="-123.118"
          gradientUnits="userSpaceOnUse"
        >
          <stop stopColor="#D04EC5" />
          <stop offset="1" stopColor="#ED7BC7" />
        </linearGradient>
      </defs>
    </svg>
  );
}

function WaveTwo() {
  return (
    <svg
      className="absolute bottom-0 left-0"
      width="500"
      height="77"
      viewBox="0 0 500 77"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <path
        d="M-1012.1 12.6512C-1057.7 8.47651 -1089.03 27.3121 -1099 37.2517V161H639V16.3785C634.328 33.0274 616.2 67.3688 581.067 71.5434C537.149 76.7617 509.117 16.3785 468.003 16.3785C426.889 16.3785 432.496 52.9066 379.234 71.5434C325.973 90.1802 290.466 31.288 240.942 16.3785C191.418 1.4691 200.762 52.9066 138.157 71.5434C75.5516 90.1802 76.4861 26.0697 15.7495 16.3785C-44.9871 6.6874 -18.8236 59.6159 -92.6419 66.3251C-166.46 73.0344 -158.051 23.8332 -222.525 12.6512C-286.999 1.46905 -281.392 37.2517 -333.719 52.9066C-386.046 68.5616 -409.406 19.3604 -486.028 2.96005C-562.649 -13.4403 -535.552 43.2155 -622.452 52.9066C-709.352 62.5978 -708.417 21.5968 -773.826 12.6512C-839.234 3.70547 -856.988 52.9066 -913.987 52.9066C-970.986 52.9066 -955.101 17.8695 -1012.1 12.6512Z"
        fill="#A416AD"
      />
    </svg>
  );
}
