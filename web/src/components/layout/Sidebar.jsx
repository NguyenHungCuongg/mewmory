import { NavLink, Link } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { useAuthStore } from "../../stores/auth.store";
import { authService } from "../../services/auth.service";
import { useUIStore } from "../../stores/ui.store";
import { useThemeStore } from "../../stores/theme.store";
import UserAvatar from "../common/UserAvatar";
import {
  IconDashboard,
  IconVocabulary,
  IconFolder,
  IconSettings,
  IconSun,
  IconMoon,
  IconMonitor,
} from "../common/Icons";

const themeIcons = {
  light: IconSun,
  dark: IconMoon,
  system: IconMonitor,
};

export default function Sidebar() {
  const { t } = useTranslation("sidebar");
  const { user, signOut: clearAuth } = useAuthStore();
  const addToast = useUIStore((s) => s.addToast);
  const { theme, toggleTheme } = useThemeStore();

  const navItems = [
    { to: "/", label: t("nav.dashboard"), icon: IconDashboard },
    { to: "/vocabulary", label: t("nav.vocabulary"), icon: IconVocabulary },
    { to: "/collections", label: t("nav.collections"), icon: IconFolder },
    { to: "/settings", label: t("nav.settings"), icon: IconSettings },
  ];

  const themeLabel = t(`theme.${theme}`, { defaultValue: t("theme.system") });
  const ThemeIcon = themeIcons[theme] || themeIcons.system;

  const handleSignOut = async () => {
    try {
      await authService.signOut();
      clearAuth();
    } catch (err) {
      addToast(t("user.signOutError"), "error");
    }
  };

  return (
    <aside className="w-60 h-screen bg-warm-taupe border-r border-stone flex flex-col fixed left-0 top-0">
      {/* Logo */}
      <Link
        to="/"
        className="p-6 pb-4 flex items-center gap-3 group select-none hover:opacity-95 transition-opacity"
      >
        <img
          src="/mewmory_icon_48.png"
          alt="Mewmory Logo"
          className="w-8 h-8 rounded-xl object-contain shadow-xs transition-transform group-hover:scale-105"
        />
        <span className="text-heading-sm font-display font-light tracking-tight text-ink">
          Mewmory
        </span>
      </Link>

      <div className="h-px bg-stone mx-4" />

      {/* Navigation */}
      <nav className="flex-1 p-4 flex flex-col gap-1">
        {navItems.map((item) => (
          <NavLink
            key={item.to}
            to={item.to}
            end={item.to === "/"}
            className={({ isActive }) =>
              `flex items-center gap-3 px-3 py-2.5 rounded-lg text-body-sm transition-colors ${
                isActive
                  ? "bg-eggshell text-ink font-medium shadow-subtle-inset"
                  : "text-smoke hover:text-ink hover:bg-eggshell/60"
              }`
            }
          >
            <item.icon className="w-4 h-4 shrink-0 text-current opacity-80" />
            <span>{item.label}</span>
          </NavLink>
        ))}
      </nav>

      {/* Theme toggle */}
      <div className="px-4 py-2">
        <button
          onClick={toggleTheme}
          title={t("theme.title", { theme: themeLabel })}
          aria-label={t("theme.ariaLabel", { theme: themeLabel })}
          className="w-full flex items-center justify-between px-3 py-2 rounded-lg text-body-sm text-smoke hover:text-ink hover:bg-eggshell/60 transition-colors cursor-pointer"
        >
          <span className="flex items-center gap-2.5">
            <ThemeIcon className="w-4 h-4 shrink-0 text-smoke" />
            <span>{t("theme.label")}</span>
          </span>
          <span className="text-caption text-smoke font-medium capitalize bg-stone/50 px-2 py-0.5 rounded-full">
            {themeLabel}
          </span>
        </button>
      </div>

      {/* User section */}
      <div className="p-4 border-t border-stone">
        {(() => {
          const displayName =
            user?.user_metadata?.display_name ||
            user?.user_metadata?.full_name ||
            user?.user_metadata?.name ||
            "";
          return (
            <div className="flex items-center gap-3 mb-3">
              <UserAvatar
                name={displayName}
                email={user?.email}
                avatarUrl={user?.user_metadata?.avatar_url}
                size="sm"
              />
              <div className="flex-1 min-w-0">
                <p className="text-body-sm font-medium text-ink truncate">
                  {displayName || user?.email || t("user.defaultName")}
                </p>
                {displayName && user?.email && (
                  <p className="text-caption text-ash truncate">{user.email}</p>
                )}
              </div>
            </div>
          );
        })()}
        <button
          onClick={handleSignOut}
          className="w-full text-left px-3 py-2 text-body-sm text-smoke hover:text-ink transition-colors rounded-lg hover:bg-eggshell/60 cursor-pointer"
        >
          {t("user.signOut")}
        </button>
      </div>
    </aside>
  );
}

