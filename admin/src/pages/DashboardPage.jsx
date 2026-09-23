import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { adminService } from "../services/admin.service";
import { supabase } from "../config/supabase";
import { useAuthStore } from "../stores/auth.store";
import StatCard from "../components/StatCard";
import { LineUsageChart } from "../components/UsageChart";
import UserTable from "../components/UserTable";

export default function DashboardPage() {
  const navigate = useNavigate();
  const { signOut } = useAuthStore();
  const [stats, setStats] = useState(null);
  const [flaggedUsers, setFlaggedUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    Promise.all([adminService.getSystemStats(), adminService.listUsers()])
      .then(([statsData, usersData]) => {
        setStats(statsData);
        setFlaggedUsers(usersData.filter((u) => u.is_flagged && !u.is_banned));
      })
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false));
  }, []);

  async function handleSignOut() {
    await supabase.auth.signOut();
    signOut();
    navigate("/login");
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-950 flex items-center justify-center">
        <div className="w-8 h-8 border-2 border-indigo-500 border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-950 text-white">
      {/* Header */}
      <header className="border-b border-white/10 px-6 py-4 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <span className="text-xl">🐱</span>
          <span className="font-semibold">Mewmory Admin</span>
        </div>
        <nav className="flex items-center gap-4">
          <button onClick={() => navigate("/dashboard")} className="text-sm text-indigo-400">Dashboard</button>
          <button onClick={() => navigate("/users")} className="text-sm text-gray-400 hover:text-white">Users</button>
          <button onClick={handleSignOut} className="text-sm text-gray-500 hover:text-red-400 transition-colors">Đăng xuất</button>
        </nav>
      </header>

      <main className="max-w-6xl mx-auto px-6 py-8">
        <h1 className="text-2xl font-semibold mb-6">Tổng quan hệ thống</h1>

        {error && (
          <div className="mb-6 p-4 rounded-xl bg-red-950/30 border border-red-500/20 text-red-400 text-sm">{error}</div>
        )}

        {stats && (
          <>
            {/* Stats Grid */}
            <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
              <StatCard icon="👥" label="Tổng Users" value={stats.total_users} />
              <StatCard icon="🟢" label="Active hôm nay" value={stats.active_today} />
              <StatCard icon="🚨" label="Cần review" value={stats.flagged_users} alert />
              <StatCard icon="📡" label="API Calls (24h)" value={stats.api_calls_24h} />
            </div>

            {/* Chart */}
            <div className="bg-white/5 border border-white/10 rounded-2xl p-6 mb-8">
              <h2 className="text-sm font-medium text-gray-400 mb-4">API calls theo giờ (24h qua)</h2>
              <LineUsageChart
                data={stats.calls_by_hour}
                xKey="hour"
                yKey="count"
                label="Calls"
              />
            </div>
          </>
        )}

        {/* Flagged Users */}
        {flaggedUsers.length > 0 && (
          <div className="bg-yellow-950/10 border border-yellow-500/20 rounded-2xl p-6">
            <h2 className="text-sm font-medium text-yellow-400 mb-4">
              🟡 Users cần review ({flaggedUsers.length})
            </h2>
            <UserTable users={flaggedUsers} />
          </div>
        )}
      </main>
    </div>
  );
}
