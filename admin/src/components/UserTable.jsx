import { useNavigate } from "react-router-dom";

function StatusBadge({ is_banned, is_flagged }) {
  if (is_banned) {
    return (
      <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-medium bg-rose-500/10 text-rose-400 border border-rose-500/20">
        <span className="w-1.5 h-1.5 rounded-full bg-rose-500"></span>
        Đã khóa
      </span>
    );
  }
  if (is_flagged) {
    return (
      <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-medium bg-amber-500/10 text-amber-400 border border-amber-500/20">
        <span className="w-1.5 h-1.5 rounded-full bg-amber-500 animate-pulse"></span>
        Cần rà soát
      </span>
    );
  }
  return (
    <span className="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-medium bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
      <span className="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>
      Hoạt động
    </span>
  );
}

export default function UserTable({ users }) {
  const navigate = useNavigate();

  if (!users.length) {
    return (
      <div className="text-center py-12 px-4">
        <p className="text-sm text-slate-400">Không tìm thấy người dùng phù hợp.</p>
      </div>
    );
  }

  return (
    <div className="overflow-x-auto">
      <table className="w-full text-sm text-left">
        <thead>
          <tr className="border-b border-slate-800 text-[11px] font-semibold tracking-wider uppercase text-slate-400 bg-slate-900/30">
            <th className="py-3 px-5">Người dùng</th>
            <th className="py-3 px-4">Tên hiển thị</th>
            <th className="py-3 px-4">Ngày đăng ký</th>
            <th className="py-3 px-4 text-right">Từ vựng</th>
            <th className="py-3 px-4 text-right">Calls (7 ngày)</th>
            <th className="py-3 px-4">Trạng thái</th>
            <th className="py-3 px-5 text-right">Hành động</th>
          </tr>
        </thead>
        <tbody className="divide-y divide-slate-800/60">
          {users.map((user) => {
            const initial = (user.display_name?.[0] || user.email?.[0] || "U").toUpperCase();
            return (
              <tr
                key={user.id}
                className="hover:bg-slate-800/30 transition-colors group"
              >
                {/* User column */}
                <td className="py-3.5 px-5">
                  <div className="flex items-center gap-3">
                    {user.avatar_url ? (
                      <img
                        src={user.avatar_url}
                        alt="avatar"
                        className="w-8 h-8 rounded-lg object-cover ring-1 ring-slate-700"
                      />
                    ) : (
                      <div className="w-8 h-8 rounded-lg bg-slate-800 border border-slate-700/60 text-slate-300 flex items-center justify-center font-medium text-xs">
                        {initial}
                      </div>
                    )}
                    <span className="font-medium text-slate-200 truncate max-w-[200px]">
                      {user.email}
                    </span>
                  </div>
                </td>

                <td className="py-3.5 px-4 text-slate-300">
                  {user.display_name || "—"}
                </td>

                <td className="py-3.5 px-4 text-slate-400 font-mono text-xs tabular-nums">
                  {new Date(user.created_at).toLocaleDateString("vi-VN")}
                </td>

                <td className="py-3.5 px-4 text-right font-mono font-medium text-slate-200 tabular-nums">
                  {user.vocab_count?.toLocaleString()}
                </td>

                <td className="py-3.5 px-4 text-right font-mono font-medium text-slate-200 tabular-nums">
                  {user.api_calls_7d?.toLocaleString()}
                </td>

                <td className="py-3.5 px-4">
                  <StatusBadge is_banned={user.is_banned} is_flagged={user.is_flagged} />
                </td>

                <td className="py-3.5 px-5 text-right">
                  <button
                    id={`view-user-${user.id}`}
                    onClick={() => navigate(`/users/${user.id}`)}
                    className="px-3 py-1.5 rounded-lg text-xs font-medium text-blue-400 bg-blue-500/10 border border-blue-500/20 hover:bg-blue-500/20 hover:text-blue-300 transition-all"
                  >
                    Xem chi tiết →
                  </button>
                </td>
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  );
}
