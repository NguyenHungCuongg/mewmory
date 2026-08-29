export default function Button({
  children,
  variant = "primary",
  size = "md",
  onClick,
  disabled = false,
  type = "button",
  className = "",
  ...props
}) {
  const base =
    "inline-flex items-center justify-center rounded-pill font-body font-medium transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed";

  const variants = {
    primary: "bg-ink text-eggshell border border-stone hover:opacity-90",
    secondary: "bg-eggshell text-ink border border-stone hover:bg-warm-taupe",
    ghost: "bg-transparent text-ink border border-stone hover:bg-warm-taupe",
  };

  const sizes = {
    sm: "px-3 py-1.5 text-body-sm",
    md: "px-4 py-2 text-body-sm",
    lg: "px-6 py-2.5 text-body",
  };

  return (
    <button
      type={type}
      onClick={onClick}
      disabled={disabled}
      className={`${base} ${variants[variant]} ${sizes[size]} ${className}`}
      {...props}
    >
      {children}
    </button>
  );
}
