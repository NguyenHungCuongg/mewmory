import { useState } from "react";

const PALETTE = [
  { bg: "#E07A5F", text: "#FFFFFF" }, // Terracotta
  { bg: "#588157", text: "#FFFFFF" }, // Sage
  { bg: "#4A6FA5", text: "#FFFFFF" }, // Slate Blue
  { bg: "#C68B59", text: "#FFFFFF" }, // Warm Ochre
  { bg: "#8E6E53", text: "#FFFFFF" }, // Warm Umber
  { bg: "#6D597A", text: "#FFFFFF" }, // Dusty Plum
  { bg: "#5F797B", text: "#FFFFFF" }, // Muted Teal
  { bg: "#3D3A34", text: "#FFFFFF" }, // Charcoal Graphite
];

function getPalette(str) {
  if (!str) return PALETTE[0];
  let hash = 0;
  for (let i = 0; i < str.length; i++) {
    hash = (hash << 5) - hash + str.charCodeAt(i);
    hash |= 0;
  }
  return PALETTE[Math.abs(hash) % PALETTE.length];
}

const SIZES = {
  sm: "w-8 h-8 text-xs font-semibold",
  md: "w-10 h-10 text-sm font-semibold",
  lg: "w-14 h-14 text-lg font-bold",
  xl: "w-20 h-20 text-2xl font-bold",
};

/**
 * Deterministic, aesthetic Avatar Generator.
 * Displays user profile image if available, or a warm palette circle with their initial.
 */
export default function UserAvatar({
  name = "",
  email = "",
  avatarUrl = null,
  size = "md",
  className = "",
}) {
  const [imageFailed, setImageFailed] = useState(false);

  const identifier = name?.trim() || email?.trim() || "?";
  const initial = identifier[0]?.toUpperCase() || "?";
  const { bg, text } = getPalette(identifier);
  const sizeClass = SIZES[size] || SIZES.md;

  if (avatarUrl && !imageFailed) {
    return (
      <img
        src={avatarUrl}
        alt={name || email || "Avatar"}
        onError={() => setImageFailed(true)}
        className={`rounded-full object-cover shadow-subtle shrink-0 ${sizeClass} ${className}`}
      />
    );
  }

  return (
    <div
      style={{ backgroundColor: bg, color: text }}
      className={`rounded-full flex items-center justify-center select-none shadow-subtle shrink-0 font-display tracking-tight transition-transform ${sizeClass} ${className}`}
      aria-label={name || email || "Avatar"}
    >
      <span>{initial}</span>
    </div>
  );
}
