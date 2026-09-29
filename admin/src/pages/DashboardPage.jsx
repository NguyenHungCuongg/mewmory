import { useEffect, useState } from "react";
import { adminService } from "../services/admin.service";
import AdminLayout from "../components/AdminLayout";
import StatCard from "../components/StatCard";
import { LineUsageChart } from "../components/UsageChart";
import UserTable from "../components/UserTable";
import { UsersIcon, ActivityIcon, AlertIcon, BookOpenIcon } from "../components/Icons";

export default function DashboardPage() {
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

  return (
    <AdminLayout
      title="Tổng quan hệ thống"
      subtitle="Giám sát thời gian thực người dùng và lưu lượng gọi API"
    >
      {loading ? (
        <div className="flex flex-col items-center justify-center py-24 gap-3">
          <div className="w-8 h-8 border-2 border-blue-500 border-t-transparent rounded-full animate-spin" />
          <span className="text-xs text-slate-400">Đang đồng bộ dữ liệu hệ thống...</span>
        </div>
      ) : (
        <div className="space-y-8 max-w-7xl">
          {error && (
            <div className="p-4 rounded-xl bg-rose-500/10 border border-rose-500/20 text-rose-400 text-sm flex items-center justify-between">
              <span>{error}</span>
              <button
                onClick={() => window.location.reload()}
                className="underline text-xs hover:text-rose-300"
              >
                Thử lại
              </button>
            </div>
          )}

          {stats && (
            <>
              {/* Stat Cards Grid */}
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                <StatCard
                  label="Tổng số người dùng"
                  value={stats.total_users}
                  icon={<UsersIcon className="w-5 h-5" />}
                  description="Toàn bộ tài khoản đã đăng ký"
                />
                <StatCard
                  label="Hoạt động hôm nay"
                  value={stats.active_today}
                  icon={<ActivityIcon className="w-5 h-5 text-emerald-400" />}
                  description="Có lượt gọi API từ 00:00"
                />
                <StatCard
                  label="Tài khoản cần rà soát"
                  value={stats.flagged_users}
                  icon={<AlertIcon className="w-5 h-5" />}
                  alert
                  description="Vượt ngưỡng >50 calls/giờ"
                />
                <StatCard
                  label="Lưu lượng API (24h)"
                  value={stats.api_calls_24h}
                  icon={<BookOpenIcon className="w-5 h-5 text-blue-400" />}
                  description="Tổng lượt tra từ & AI phân loại"
                />
              </div>

              {/* Chart Card */}
              <div className="bg-[#0f1523] border border-slate-800/80 rounded-2xl p-6 shadow-sm">
                <div className="flex items-center justify-between mb-6">
                  <div>
                    <h2 className="text-sm font-semibold text-slate-200">
                      Biểu đồ lưu lượng API theo giờ
                    </h2>
                    <p className="text-xs text-slate-400 mt-0.5">
                      Thống kê 24 mốc thời gian gần nhất trong ngày
                    </p>
                  </div>
                  <span className="px-2.5 py-1 rounded-lg text-xs font-mono bg-slate-800 text-slate-300 border border-slate-700/60">
                    24 giờ qua
                  </span>
                </div>

                <LineUsageChart
                  data={stats.calls_by_hour}
                  xKey="hour"
                  yKey="count"
                  label="Calls"
                />
              </div>
            </>
          )}

          {/* Flagged Users Section */}
          <div className="bg-[#0f1523] border border-slate-800/80 rounded-2xl overflow-hidden shadow-sm">
            <div className="p-5 border-b border-slate-800/80 flex items-center justify-between">
              <div>
                <h2 className="text-sm font-semibold text-slate-200 flex items-center gap-2">
                  <span>Tài khoản có dấu hiệu spam</span>
                  <span className="px-2 py-0.5 rounded-full text-xs font-mono font-medium bg-amber-500/10 text-amber-400 border border-amber-500/20">
                    {flaggedUsers.length}
                  </span>
                </h2>
                <p className="text-xs text-slate-400 mt-0.5">
                  Các tài khoản được hệ thống tự động gắn cờ để Admin kiểm tra
                </p>
              </div>
            </div>

            {flaggedUsers.length > 0 ? (
              <UserTable users={flaggedUsers} />
            ) : (
              <div className="py-12 text-center">
                <p className="text-sm text-slate-400">
                  Không có tài khoản nào bị gắn cờ cảnh báo. Hệ thống an toàn.
                </p>
              </div>
            )}
          </div>
        </div>
      )}
    </AdminLayout>
  );
}
