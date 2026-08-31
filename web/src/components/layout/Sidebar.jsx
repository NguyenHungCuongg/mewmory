import { NavLink } from "react-router-dom";
import { useAuthStore } from "../../stores/auth.store";
import { authService } from "../../services/auth.service";
import { useUIStore } from "../../stores/ui.store";

const navItems = [
  { to: "/", label: "Dashboard", icon: "📊" },
  { to: "/vocabulary", label: "Từ vựng", icon: "📖" },
  { to: "/collections", label: "Collections", icon: "📚" },
  { to: "/settings", label: "Cài đặt", icon: "⚙️" },
];

export default function Sidebar() {
  const { user, signOut: clearAuth } = useAuthStore();
  const addToast = useUIStore((s) => s.addToast);

  const handleSignOut = async () => {
    try {
      await authService.signOut();
      clearAuth();
    } catch (err) {
      addToast("Lỗi đăng xuất", "error");
    }
  };

  return (
    <aside className="w-60 h-screen bg-warm-taupe border-r border-stone flex flex-col fixed left-0 top-0">
      {/* Logo */}
      <div className="p-6 pb-4">
        <h1 className="text-heading-sm font-display font-light tracking-tight">
          Mewmory
        </h1>
      </div>

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
            <span>{item.icon}</span>
            {item.label}
          </NavLink>
        ))}
      </nav>

      {/* User section */}
      <div className="p-4 border-t border-stone">
        <div className="flex items-center gap-3 mb-3">
          <div className="w-8 h-8 rounded-full bg-stone flex items-center justify-center text-caption text-graphite">
            {user?.email?.[0]?.toUpperCase() || "?"}
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-body-sm text-ink truncate">
              {user?.email || "User"}
            </p>
          </div>
        </div>
        <button
          onClick={handleSignOut}
          className="w-full text-left px-3 py-2 text-body-sm text-smoke hover:text-ink transition-colors rounded-lg hover:bg-eggshell/60"
        >
          Đăng xuất
        </button>
      </div>
    </aside>
  );
}
