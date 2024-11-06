import { useEffect } from "react";

type TColorMode = "LIGHT" | "DARK" | null;

export function ColorToggle() {
  useEffect(() => {
    const colorMode = localStorage.getItem("colorMode") as TColorMode;
    if (colorMode === "DARK") {
      document.documentElement.classList.add("dark");
      return;
    }
    if (colorMode === "LIGHT") return;
    if (
      window.matchMedia &&
      window.matchMedia("(prefers-color-scheme: dark)").matches
    ) {
      document.documentElement.classList.add("dark");
    }
  }, []);

  function handleColorToggle() {
    if (document.documentElement.classList.contains("dark")) {
      document.documentElement.classList.remove("dark");
      localStorage.setItem("colorMode", "LIGHT");
    } else {
      localStorage.setItem("colorMode", "DARK");
      document.documentElement.classList.add("dark");
    }
  }

  return (
    <button
      aria-label="toggle light and dark mode"
      className="flex items-center gap-2 px-4 py-2"
      onClick={handleColorToggle}
    >
      <div className="h-6 w-6 text-breadgray-grey dark:text-breadpink-shaded">
        <MoonIcon />
      </div>
      <div className="text-breadgray-light-grey w-[1px] opacity-60">
        <Divider />
      </div>
      <div className="h-6 w-6 text-breadpink-shaded dark:text-breadgray-grey">
        <SunIcon />
      </div>
    </button>
  );
}

function MoonIcon() {
  return (
    <svg
      viewBox="0 0 24 24"
      className="h-full w-full fill-current"
      xmlns="http://www.w3.org/2000/svg"
    >
      <path
        fillRule="evenodd"
        clipRule="evenodd"
        d="M6 2h8v2h-2v2h-2V4H6V2ZM4 6V4h2v2H4Zm0 10H2V6h2v10Zm2 2H4v-2h2v2Zm2 2H6v-2h2v2Zm10 0v2H8v-2h10Zm2-2v2h-2v-2h2Zm-2-4h2v4h2v-6h-2v2h-2v2Zm-6 0v2h6v-2h-6Zm-2-2h2v2h-2v-2Zm0 0V6H8v6h2Z"
      />
    </svg>
  );
}

function SunIcon() {
  return (
    <svg
      viewBox="0 0 24 24"
      className="h-full w-full fill-current"
      xmlns="http://www.w3.org/2000/svg"
    >
      <g clipPath="url(#sun_icon)">
        <path
          fillRule="evenodd"
          clipRule="evenodd"
          d="M13 0h-2v4h2V0ZM0 11v2h4v-2H0Zm24 0v2h-4v-2h4ZM13 24h-2v-4h2v4ZM8 6h8v2H8V6ZM6 8h2v8H6V8Zm2 10v-2h8v2H8Zm10-2h-2V8h2v8Zm2-14h2v2h-2V2Zm0 2v2h-2V4h2Zm2 18h-2v-2h2v2Zm-2-2h-2v-2h2v2ZM4 2H2v2h2v2h2V4H4V2ZM2 22h2v-2h2v-2H4v2H2v2Z"
        />
      </g>
      <defs>
        <clipPath id="sun_icon">
          <path fill="#fff" d="M0 0h24v24H0z" />
        </clipPath>
      </defs>
    </svg>
  );
}

function Divider() {
  return (
    <svg
      viewBox="0 0 1 20"
      className="fill-current"
      xmlns="http://www.w3.org/2000/svg"
    >
      <rect width="1" height="20" />
    </svg>
  );
}
