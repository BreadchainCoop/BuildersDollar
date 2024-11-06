import Link from "next/link";
import { LogoSVG } from "../Icons/Logo";

export function Logo() {
  return (
    <div className="flex items-center">
      <Link href="/" className="w-8 h-8">
        <LogoSVG />
      </Link>
    </div>
  );
}

export default Logo;
