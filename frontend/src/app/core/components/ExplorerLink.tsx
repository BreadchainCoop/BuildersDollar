import { ExternalLink } from "./Icons/ExternalLink";

export function ExplorerLink({ to }: { to: string }) {
  return (
    <a
      target="_blank"
      rel="noopener noreferer"
      href={to}
      className="flex items-center justify-center gap-1 text-breadpink-shaded"
    >
      <span className="font-medium">View on Explorer</span>
      <span className="w-5 h-5">
        <ExternalLink />
      </span>
    </a>
  );
}
