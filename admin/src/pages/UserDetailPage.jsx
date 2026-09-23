import { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { adminService } from "../services/admin.service";
import { supabase } from "../config/supabase";
import { useAuthStore } from "../stores/auth.store";
import { BarUsageChart } from "../components/UsageChart";
import BanModal from "../components/BanModal";

const ACTION_LABELS = {
  lookup_word: "Tra từ",
  ai_classify: "AI phân loại",
  translate_definition: "Dịch nghĩa",
};
const STATUS_STYLES = {
  success: "text-green-400",
  error: "text-red-400",
  rate_limited: "text-yellow-400",
  banned: "text-red-500",
};

export default function UserDetailPage() {
  const { userId } = useParams();
  const navigate = useNavigate();
  const { signOut } = useAuthStore();
  const [detail, setDetail] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [showBanModal, setShowBanModal] = useState(false);
  const [actionLoading, setActionLoading] = useState(false);
  const [actionSuccess, setActionSuccess] = useState("");

  useEffect(() => {
    adminService
      .getUserDetail(userId)
      .then(setDetail)
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false));
  }, [userId]);

  async function handleSignOut() {
    await supabase.auth.signOut();
    signOut();
    navigate("/login");
  }

  async function handleBan(reason) {
    setActionLoading(true);
    try {
      await adminService.banUser(userId, reason);
      setShowBanModal(false);
      setActionSuccess("User đã bị suspend thành công.");
      // Refresh
      const updated = await adminService.getUserDetail(userId);
      setDetail(updated);
    } catch (err) {
      setError(err.message);
    } finally {
      setActionLoading(false);
    }
  }

  async function handleUnban() {
    setActionLoading(true);
    try {
      await adminService.unbanUser(userId);
      setActionSuccess("User đã được unban.");
      const updated = await adminService.getUserDetail(userId);
      setDetail(updated);
    } catch (err) {
      setError(err.message);
    } finally {
      setActionLoading(false);
    }
  }

  async function handleUnflag() {
    setActionLoading(true);
    try {
      await adminService.unflagUser(userId);
      setActionSuccess("Đã bỏ flag user.");
      const updated = await adminService.getUserDetail(userId);
      setDetail(updated);
    } catch (err) {
      setError(err.message);
    } finally {
      setActionLoading(false);
    }
  }

  const profile = detail?.profile;

  return (
    <div className="min-h-screen bg-gray-950 text-white">
      <header className="border-b border-white/10 px-6 py-4 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <span className="text-xl">🐱</span>
          <span className="font-semibold">Mewmory Admin</span>
        </div>
        <nav className="flex items-center gap-4">
          <button onClick={() => navigate("/dashboard")} className="text-sm text-gray-400 hover:text-white">Dashboard</button>
          <button onClick={() => navigate("/users")} className="text-sm text-gray-400 hover:text-white">Users</button>
          <button onClick={handleSignOut} className="text-sm text-gray-500 hover:text-red-400 transition-colors">Đăng xuất</button>
        </nav>
      </header>

      <main className="max-w-5xl mx-auto px-6 py-8">
        <button
          onClick={() => navigate("/users")}
          className="text-sm text-gray-400 hover:text-white mb-6 inline-flex items-center gap-1"
        >
          ← Quay lại danh sách
        </button>

        {loading && (
          <div className="flex justify-center py-16">
            <div className="w-8 h-8 border-2 border-indigo-500 border-t-transparent rounded-full animate-spin" />
          </div>
        )}

        {error && (
          <div className="mb-4 p-4 rounded-xl bg-red-950/30 border border-red-500/20 text-red-400 text-sm">{error}</div>
        )}

        {actionSuccess && (
          <div className="mb-4 p-4 rounded-xl bg-green-950/30 border border-green-500/20 text-green-400 text-sm">{actionSuccess}</div>
        )}

        {detail && profile && (
          <>
            {/* Profile Header */}
            <div className="bg-white/5 border border-white/10 rounded-2xl p-6 mb-6 flex items-start justify-between flex-wrap gap-4">
              <div className="flex items-center gap-4">
                {profile.avatar_url ? (
                  <img src={profile.avatar_url} alt="avatar" className="w-14 h-14 rounded-full object-cover" />
                ) : (
                  <div className="w-14 h-14 rounded-full bg-indigo-900/40 flex items-center justify-center text-2xl">
                    {(profile.display_name || profile.email)?.[0]?.toUpperCase()}
                  </div>
                )}
                <div>
                  <h1 className="text-lg font-semibold text-white">{profile.display_name || "—"}</h1>
                  <p className="text-sm text-gray-400">{profile.email}</p>
                  <p className="text-xs text-gray-500 mt-0.5">
                    Joined {new Date(profile.created_at).toLocaleDateString("vi-VN")} ·{" "}
                    Last active:{" "}
                    {profile.last_active_at
                      ? new Date(profile.last_active_at).toLocaleString("vi-VN")
                      : "Chưa từng active"}
                  </p>
                </div>
              </div>
              {/* Actions */}
              <div className="flex flex-col items-end gap-2">
                {profile.is_flagged && !profile.is_banned && (
                  <button
                    id="unflag-btn"
                    onClick={handleUnflag}
                    disabled={actionLoading}
                    className="px-4 py-1.5 rounded-xl border border-yellow-500/30 text-yellow-400 text-sm hover:bg-yellow-900/20 transition-colors disabled:opacity-50"
                  >
                    Bỏ flag
                  </button>
                )}
                {!profile.is_banned ? (
                  <button
                    id="suspend-btn"
                    onClick={() => setShowBanModal(true)}
                    disabled={actionLoading}
                    className="px-4 py-1.5 rounded-xl bg-red-600/20 border border-red-500/30 text-red-400 text-sm hover:bg-red-600/30 transition-colors disabled:opacity-50"
                  >
                    🔴 Suspend User
                  </button>
                ) : (
                  <div className="text-right">
                    <div className="text-xs text-gray-500 mb-1">
                      Banned {new Date(profile.banned_at).toLocaleString("vi-VN")}
                    </div>
                    <div className="text-xs text-gray-400 mb-2 max-w-[200px] text-right">
                      Lý do: {profile.ban_reason}
                    </div>
                    <button
                      id="unban-btn"
                      onClick={handleUnban}
                      disabled={actionLoading}
                      className="px-4 py-1.5 rounded-xl bg-green-600/20 border border-green-500/30 text-green-400 text-sm hover:bg-green-600/30 transition-colors disabled:opacity-50"
                    >
                      ✅ Unban
                    </button>
                  </div>
                )}
              </div>
            </div>

            {/* Stats Row */}
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-4 mb-6">
              {[
                { label: "Từ vựng", value: profile.vocab_count },
                { label: "Calls hôm nay", value: profile.api_calls_today },
                { label: "Calls 7 ngày", value: profile.api_calls_7d },
                { label: "Tổng calls", value: profile.api_calls_total },
              ].map(({ label, value }) => (
                <div key={label} className="bg-white/5 border border-white/10 rounded-2xl p-4">
                  <div className="text-xs text-gray-400 mb-1">{label}</div>
                  <div className="text-xl font-semibold text-white">{value?.toLocaleString() ?? "—"}</div>
                </div>
              ))}
            </div>

            {/* Charts */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-6 mb-6">
              <div className="bg-white/5 border border-white/10 rounded-2xl p-5">
                <h3 className="text-sm text-gray-400 mb-3">Calls theo ngày (7 ngày)</h3>
                <BarUsageChart data={detail.daily_calls} xKey="date" yKey="count" label="Calls" />
              </div>
              <div className="bg-white/5 border border-white/10 rounded-2xl p-5">
                <h3 className="text-sm text-gray-400 mb-3">Calls theo giờ (24h qua)</h3>
                <BarUsageChart data={detail.hourly_calls} xKey="hour" yKey="count" label="Calls" />
              </div>
            </div>

            {/* Activity Log */}
            <div className="bg-white/5 border border-white/10 rounded-2xl overflow-hidden">
              <div className="px-5 py-4 border-b border-white/10">
                <h3 className="text-sm font-medium text-gray-300">50 hoạt động gần nhất</h3>
              </div>
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead>
                    <tr className="border-b border-white/10">
                      {["Thời gian", "Action", "Từ", "Kết quả"].map((h) => (
                        <th key={h} className="text-left py-2.5 px-4 text-gray-400 font-medium text-xs">{h}</th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {detail.recent_logs.map((log) => (
                      <tr key={log.id} className="border-b border-white/5">
                        <td className="py-2.5 px-4 text-gray-500 text-xs whitespace-nowrap">
                          {new Date(log.created_at).toLocaleString("vi-VN")}
                        </td>
                        <td className="py-2.5 px-4 text-gray-300 text-xs">
                          {ACTION_LABELS[log.action] || log.action}
                        </td>
                        <td className="py-2.5 px-4 text-gray-400 text-xs font-mono">
                          {log.word || "—"}
                        </td>
                        <td className={`py-2.5 px-4 text-xs ${STATUS_STYLES[log.status] || "text-gray-400"}`}>
                          {log.status}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          </>
        )}
      </main>

      {showBanModal && (
        <BanModal
          onConfirm={handleBan}
          onCancel={() => setShowBanModal(false)}
          isLoading={actionLoading}
        />
      )}
    </div>
  );
}
