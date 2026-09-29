import { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { adminService } from "../services/admin.service";
import AdminLayout from "../components/AdminLayout";
import { BarUsageChart } from "../components/UsageChart";
import BanModal from "../components/BanModal";
import { ArrowLeftIcon, ShieldAlertIcon, CheckCircleIcon } from "../components/Icons";

const ACTION_LABELS = {
  lookup_word: "Tra từ điển",
  ai_classify: "AI phân loại",
  translate_definition: "Dịch nghĩa AI",
};

function LogStatusBadge({ status }) {
  if (status === "success") {
    return (
      <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[11px] font-mono font-medium text-emerald-400 bg-emerald-500/10 border border-emerald-500/20">
        success
      </span>
    );
  }
  if (status === "banned") {
    return (
      <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[11px] font-mono font-medium text-rose-400 bg-rose-500/10 border border-rose-500/20">
        banned
      </span>
    );
  }
  if (status === "rate_limited") {
    return (
      <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[11px] font-mono font-medium text-amber-400 bg-amber-500/10 border border-amber-500/20">
        rate_limited
      </span>
    );
  }
  return (
    <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded text-[11px] font-mono font-medium text-rose-400 bg-rose-500/10 border border-rose-500/20">
      error
    </span>
  );
}

export default function UserDetailPage() {
  const { userId } = useParams();
  const navigate = useNavigate();
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

  async function handleBan(reason) {
    setActionLoading(true);
    try {
      await adminService.banUser(userId, reason);
      setShowBanModal(false);
      setActionSuccess("Người dùng đã bị khóa quyền gọi API thành công.");
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
      setActionSuccess("Đã gỡ khóa tài khoản người dùng.");
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
      setActionSuccess("Đã gỡ cờ cảnh báo spam cho người dùng.");
      const updated = await adminService.getUserDetail(userId);
      setDetail(updated);
    } catch (err) {
      setError(err.message);
    } finally {
      setActionLoading(false);
    }
  }

  const profile = detail?.profile;
  const initial = (profile?.display_name?.[0] || profile?.email?.[0] || "U").toUpperCase();

  return (
    <AdminLayout
      title="Hồ sơ chi tiết người dùng"
      subtitle={profile?.email || "Chi tiết tài khoản & Lịch sử sử dụng"}
    >
      <div className="space-y-6 max-w-6xl">
        {/* Navigation Bar */}
        <div className="flex items-center justify-between">
          <button
            onClick={() => navigate("/users")}
            className="inline-flex items-center gap-2 px-3 py-1.5 rounded-xl border border-slate-700/80 bg-[#0f1523] text-xs font-medium text-slate-300 hover:text-white hover:bg-slate-800/80 transition-all"
          >
            <ArrowLeftIcon className="w-3.5 h-3.5" />
            <span>Quay lại danh sách</span>
          </button>
        </div>

        {loading && (
          <div className="flex flex-col items-center justify-center py-20 gap-3">
            <div className="w-8 h-8 border-2 border-blue-500 border-t-transparent rounded-full animate-spin" />
            <span className="text-xs text-slate-400">Đang truy xuất dữ liệu chi tiết...</span>
          </div>
        )}

        {error && (
          <div className="p-4 rounded-xl bg-rose-500/10 border border-rose-500/20 text-rose-400 text-sm">
            {error}
          </div>
        )}

        {actionSuccess && (
          <div className="p-4 rounded-xl bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-sm flex items-center justify-between">
            <span>{actionSuccess}</span>
            <button
              onClick={() => setActionSuccess("")}
              className="text-xs text-emerald-400 hover:underline"
            >
              Đóng
            </button>
          </div>
        )}

        {detail && profile && (
          <>
            {/* Header Profile Card */}
            <div className="bg-[#0f1523] border border-slate-800/80 rounded-2xl p-6 shadow-sm flex flex-col md:flex-row md:items-center justify-between gap-6">
              <div className="flex items-center gap-4">
                {profile.avatar_url ? (
                  <img
                    src={profile.avatar_url}
                    alt="avatar"
                    className="w-14 h-14 rounded-2xl object-cover ring-2 ring-slate-700"
                  />
                ) : (
                  <div className="w-14 h-14 rounded-2xl bg-blue-600/20 border border-blue-500/30 text-blue-400 flex items-center justify-center text-xl font-bold font-mono">
                    {initial}
                  </div>
                )}
                <div>
                  <div className="flex items-center gap-2.5">
                    <h2 className="text-lg font-semibold text-white tracking-tight">
                      {profile.display_name || "Chưa đặt tên"}
                    </h2>
                    {profile.is_banned ? (
                      <span className="px-2 py-0.5 rounded-full text-xs font-medium bg-rose-500/15 text-rose-400 border border-rose-500/30">
                        Đã khóa
                      </span>
                    ) : profile.is_flagged ? (
                      <span className="px-2 py-0.5 rounded-full text-xs font-medium bg-amber-500/15 text-amber-400 border border-amber-500/30">
                        Cần rà soát
                      </span>
                    ) : (
                      <span className="px-2 py-0.5 rounded-full text-xs font-medium bg-emerald-500/15 text-emerald-400 border border-emerald-500/30">
                        Hoạt động
                      </span>
                    )}
                  </div>
                  <p className="text-xs text-slate-400 font-mono mt-0.5">{profile.email}</p>
                  <p className="text-[11px] text-slate-400 mt-1">
                    Đăng ký ngày:{" "}
                    <span className="text-slate-300 font-mono">
                      {new Date(profile.created_at).toLocaleDateString("vi-VN")}
                    </span>{" "}
                    · Hoạt động gần nhất:{" "}
                    <span className="text-slate-300 font-mono">
                      {profile.last_active_at
                        ? new Date(profile.last_active_at).toLocaleString("vi-VN")
                        : "Chưa có"}
                    </span>
                  </p>
                </div>
              </div>

              {/* Action Controls */}
              <div className="flex items-center gap-2.5 flex-wrap">
                {profile.is_flagged && !profile.is_banned && (
                  <button
                    id="unflag-btn"
                    onClick={handleUnflag}
                    disabled={actionLoading}
                    className="inline-flex items-center gap-1.5 px-3.5 py-2 rounded-xl text-xs font-medium bg-amber-500/10 border border-amber-500/20 text-amber-400 hover:bg-amber-500/20 disabled:opacity-50 transition-all"
                  >
                    <CheckCircleIcon className="w-4 h-4" />
                    <span>Gỡ cảnh báo</span>
                  </button>
                )}

                {!profile.is_banned ? (
                  <button
                    id="suspend-btn"
                    onClick={() => setShowBanModal(true)}
                    disabled={actionLoading}
                    className="inline-flex items-center gap-1.5 px-3.5 py-2 rounded-xl text-xs font-medium bg-rose-600/15 border border-rose-500/30 text-rose-400 hover:bg-rose-600/25 disabled:opacity-50 transition-all shadow-sm"
                  >
                    <ShieldAlertIcon className="w-4 h-4" />
                    <span>Khóa tài khoản</span>
                  </button>
                ) : (
                  <div className="flex items-center gap-3">
                    <div className="text-right">
                      <p className="text-[11px] text-rose-400 font-medium">
                        Lý do: {profile.ban_reason || "Vi phạm điều khoản"}
                      </p>
                      <p className="text-[10px] text-slate-400 font-mono">
                        {profile.banned_at ? new Date(profile.banned_at).toLocaleString("vi-VN") : ""}
                      </p>
                    </div>
                    <button
                      id="unban-btn"
                      onClick={handleUnban}
                      disabled={actionLoading}
                      className="px-3.5 py-2 rounded-xl text-xs font-medium bg-emerald-600/15 border border-emerald-500/30 text-emerald-400 hover:bg-emerald-600/25 disabled:opacity-50 transition-all shadow-sm"
                    >
                      Mở khóa tài khoản
                    </button>
                  </div>
                )}
              </div>
            </div>

            {/* Metrics Grid */}
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              {[
                { label: "Tổng từ vựng", val: profile.vocab_count, unit: "từ" },
                { label: "Calls hôm nay", val: profile.api_calls_today, unit: "calls" },
                { label: "Calls 7 ngày", val: profile.api_calls_7d, unit: "calls" },
                { label: "Tổng lưu lượng calls", val: profile.api_calls_total, unit: "calls" },
              ].map((m) => (
                <div key={m.label} className="bg-[#0f1523] border border-slate-800/80 rounded-2xl p-4 shadow-sm">
                  <span className="text-xs font-medium uppercase tracking-wider text-slate-400">{m.label}</span>
                  <div className="mt-2 flex items-baseline gap-1.5">
                    <span className="text-2xl font-semibold font-mono tabular-nums text-white">
                      {m.val?.toLocaleString() ?? 0}
                    </span>
                    <span className="text-xs text-slate-400 font-mono">{m.unit}</span>
                  </div>
                </div>
              ))}
            </div>

            {/* Charts Row */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              <div className="bg-[#0f1523] border border-slate-800/80 rounded-2xl p-5 shadow-sm">
                <h3 className="text-xs font-semibold uppercase tracking-wider text-slate-300 mb-1">
                  Lưu lượng theo ngày (7 ngày qua)
                </h3>
                <p className="text-[11px] text-slate-400 mb-4">Mật độ sử dụng trong tuần</p>
                <BarUsageChart data={detail.daily_calls} xKey="date" yKey="count" label="Calls" />
              </div>

              <div className="bg-[#0f1523] border border-slate-800/80 rounded-2xl p-5 shadow-sm">
                <h3 className="text-xs font-semibold uppercase tracking-wider text-slate-300 mb-1">
                  Lưu lượng theo giờ (24 giờ qua)
                </h3>
                <p className="text-[11px] text-slate-400 mb-4">Các khung giờ gọi API trong ngày</p>
                <BarUsageChart data={detail.hourly_calls} xKey="hour" yKey="count" label="Calls" />
              </div>
            </div>

            {/* Activity Logs Table */}
            <div className="bg-[#0f1523] border border-slate-800/80 rounded-2xl overflow-hidden shadow-sm">
              <div className="px-5 py-4 border-b border-slate-800/80 flex items-center justify-between">
                <div>
                  <h3 className="text-sm font-semibold text-slate-200">50 hoạt động API gần nhất</h3>
                  <p className="text-xs text-slate-400 mt-0.5">Nhật ký chi tiết các lệnh gọi Edge Functions</p>
                </div>
                <span className="px-2 py-0.5 rounded text-xs font-mono bg-slate-800 text-slate-400 border border-slate-700/60">
                  {detail.recent_logs?.length || 0} bản ghi
                </span>
              </div>

              <div className="overflow-x-auto">
                <table className="w-full text-xs text-left">
                  <thead>
                    <tr className="border-b border-slate-800 text-[11px] font-semibold tracking-wider uppercase text-slate-400 bg-slate-900/30">
                      <th className="py-2.5 px-5">Thời gian</th>
                      <th className="py-2.5 px-4">Thao tác</th>
                      <th className="py-2.5 px-4">Từ khóa</th>
                      <th className="py-2.5 px-4">Kết quả</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-800/60">
                    {detail.recent_logs?.map((log) => (
                      <tr key={log.id} className="hover:bg-slate-800/30 transition-colors">
                        <td className="py-2.5 px-5 text-slate-400 font-mono whitespace-nowrap">
                          {new Date(log.created_at).toLocaleString("vi-VN")}
                        </td>
                        <td className="py-2.5 px-4 font-medium text-slate-200">
                          {ACTION_LABELS[log.action] || log.action}
                        </td>
                        <td className="py-2.5 px-4 font-mono text-slate-300">
                          {log.word || "—"}
                        </td>
                        <td className="py-2.5 px-4">
                          <LogStatusBadge status={log.status} />
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          </>
        )}
      </div>

      {showBanModal && (
        <BanModal
          onConfirm={handleBan}
          onCancel={() => setShowBanModal(false)}
          isLoading={actionLoading}
        />
      )}
    </AdminLayout>
  );
}
