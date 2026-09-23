import { NavLink, useNavigate } from "react-router-dom";
import { supabase } from "../config/supabase";
import { useAuthStore } from "../stores/auth.store";
import {
  DashboardIcon,
  UsersIcon,
  LogOutIcon,
  MewmoryLogo,
} from "./Icons";

export default function AdminLayout({ title, subtitle, children }) {
  const navigate = useNavigate();
  const { user, signOut } = useAuthStore();

  async function handleSignOut() {
    await supabase.auth.signOut();
    signOut();
    navigate("/login");
  }

  const userInitial = (user?.email?.[0] || "A").toUpperCase();

  return (
    <div className="min-h-screen bg-[#090d16] text-slate-100 flex">
      {/* ── Left Sidebar ──────────────────────────────────────────────── */}
      <aside className="w-64 border-r border-slate-800/80 bg-[#0d131f] flex flex-col justify-between shrink-0 select-none">
        <div>
          {/* Brand */}
          <div className="h-16 px-6 flex items-center gap-3 border-b border-slate-800/80">
            <MewmoryLogo className="w-8 h-8 rounded-lg shadow-sm" />
            <div>
              <div className="flex items-center gap-2">
                <span className="font-semibold text-base tracking-tight text-white">Mewmory</span>
                <span className="px-1.5 py-0.5 text-[10px] font-semibold tracking-wider uppercase rounded bg-blue-500/10 text-blue-400 border border-blue-500/20">
                  Admin
                </span>
              </div>
              <p className="text-[11px] text-slate-400">Internal Control Panel</p>
            </div>
          </div>

          {/* Navigation Links */}
          <div className="p-4 space-y-1">
            <div className="px-3 py-1.5 text-[11px] font-medium tracking-wider uppercase text-slate-400">
              Quản trị hệ thống
            </div>

            <NavLink
              to="/dashboard"
              className={({ isActive }) =>
                `flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-all ${
                  isActive
                    ? "bg-blue-600/15 text-blue-400 border border-blue-500/20 shadow-sm"
                    : "text-slate-400 hover:text-slate-200 hover:bg-slate-800/50"
                }`
              }
            >
              <DashboardIcon className="w-4 h-4" />
              <span>Tổng quan</span>
            </NavLink>

            <NavLink
              to="/users"
              className={({ isActive }) =>
                `flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-all ${
                  isActive
                    ? "bg-blue-600/15 text-blue-400 border border-blue-500/20 shadow-sm"
                    : "text-slate-400 hover:text-slate-200 hover:bg-slate-800/50"
                }`
              }
            >
              <UsersIcon className="w-4 h-4" />
              <span>Người dùng</span>
            </NavLink>
          </div>
        </div>

        {/* Sidebar Footer */}
        <div className="p-4 border-t border-slate-800/80 space-y-3">
          {/* System status pill */}
          <div className="px-3 py-2 rounded-xl bg-slate-900/80 border border-slate-800/90 flex items-center justify-between text-xs">
            <span className="text-slate-400">Trạng thái API</span>
            <div className="flex items-center gap-1.5">
              <span className="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
              <span className="text-emerald-400 font-medium">Hoạt động</span>
            </div>
          </div>

          {/* User profile & Logout */}
          <div className="flex items-center justify-between gap-2 px-1">
            <div className="flex items-center gap-2.5 min-w-0">
              <div className="w-8 h-8 rounded-full bg-blue-600/20 border border-blue-500/30 text-blue-400 flex items-center justify-center font-medium text-xs shrink-0">
                {userInitial}
              </div>
              <div className="min-w-0">
                <div className="text-xs font-medium text-slate-200 truncate">
                  {user?.email || "Admin User"}
                </div>
                <div className="text-[10px] text-slate-400">Super Admin</div>
              </div>
            </div>

            <button
              onClick={handleSignOut}
              title="Đăng xuất"
              className="p-1.5 rounded-lg text-slate-400 hover:text-rose-400 hover:bg-rose-500/10 transition-colors shrink-0"
            >
              <LogOutIcon className="w-4 h-4" />
            </button>
          </div>
        </div>
      </aside>

      {/* ── Main Workspace ────────────────────────────────────────────── */}
      <div className="flex-1 flex flex-col min-w-0">
        {/* Top Header */}
        <header className="h-16 px-8 border-b border-slate-800/80 bg-[#0c111c]/60 backdrop-blur-md flex items-center justify-between shrink-0">
          <div>
            <h1 className="text-base font-semibold text-white tracking-tight">{title}</h1>
            {subtitle && <p className="text-xs text-slate-400">{subtitle}</p>}
          </div>

          <div className="flex items-center gap-3">
            <span className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs bg-slate-800/70 border border-slate-700/60 text-slate-300">
              <span className="w-1.5 h-1.5 rounded-full bg-blue-400"></span>
              Mewmory Edge Platform
            </span>
          </div>
        </header>

        {/* Page Content Body */}
        <main className="flex-1 p-8 overflow-y-auto">
          {children}
        </main>
      </div>
    </div>
  );
}
