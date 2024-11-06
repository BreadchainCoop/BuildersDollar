import Image from "next/image";
import { BreadSVG } from "./Bread";
import clsx from "clsx";

export function XDAIIcon() {
  return (
    <div className="rounded-full overflow-hidden w-6 h-6">
      <Image src={"/xdai_icon.png"} alt="xdai icon" width="30" height="30" />
    </div>
  );
}

// export function BreadIcon() {
//   return (
//     <div className="rounded-full w-6 h-6 bg-breadpink-200 bg-opacity-10 dark:bg-breadgray-rye flex items-center justify-center">
//       <div className="w-2/3 transform translate-y-[1px]">
//         <LogoSVG />
//       </div>
//     </div>
//   );
// }

export function BreadIcon({
  size = "regular",
}: {
  size?: "small" | "regular";
}) {
  return (
    <div
      className={clsx(
        "rounded-full bg-breadpink-200 bg-opacity-10 dark:bg-breadgray-rye flex items-center justify-center",
        size === "small" ? "size-4" : "size-6"
      )}
    >
      <div>
        <BreadSVG size={size} />
      </div>
    </div>
  );
}
