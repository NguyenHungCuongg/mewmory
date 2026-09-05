import OfflineBadge from "../common/OfflineBadge";

export default function Header({ title, actions }) {
  return (
    <header className="h-14 border-b border-stone bg-eggshell flex items-center justify-between px-6">
      <h2 className="text-subheading font-display font-light">{title}</h2>
      <div className="flex items-center gap-4">
        {actions}
        <OfflineBadge />
      </div>
    </header>
  );
}
