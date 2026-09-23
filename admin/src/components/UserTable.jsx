import { useNavigate } from "react-router-dom";

function StatusBadge({ is_banned, is_flagged }) {
  if (is_banned) return <span className="px-2 py-0.5 rounded-full text-xs bg-red-900/40 text-red-300 border border-red-500/30">🔴 Banned</span>;
  if (is_flagged) return <span className="px-2 py-0.5 rounded-full text-xs bg-yellow-900/40 text-yellow-300 border border-yellow-500/30">🟡 Flagged</span>;
  return <span className="px-2 py-0.5 rounded-full text-xs bg-green-900/40 text-green-300 border border-green-500/30">🟢 Active</span>;
}

export default function UserTable({ users }) {
  const navigate = useNavigate();

  if (!users.length) {
    return <p className="text-center text-gray-500 py-10">Không có user nào.</p>;
  }

  return (
    <div className="overflow-x-auto">
      <table className="w-full text-sm">
        <thead>
          <tr className="border-b border-white/10">
            {["Email", "Tên", "Ngày join", "Vocab", "Calls (7d)", "Trạng thái", ""].map((h) => (
              <th key={h} className="text-left py-3 px-4 text-gray-400 font-medium">{h}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {users.map((user) => (
            <tr
              key={user.id}
              className="border-b border-white/5 hover:bg-white/3 transition-colors"
            >
              <td className="py-3 px-4 text-gray-200 max-w-[200px] truncate">{user.email}</td>
              <td className="py-3 px-4 text-gray-300">{user.display_name || "—"}</td>
              <td className="py-3 px-4 text-gray-400">
                {new Date(user.created_at).toLocaleDateString("vi-VN")}
              </td>
              <td className="py-3 px-4 text-gray-300">{user.vocab_count}</td>
              <td className="py-3 px-4 text-gray-300">{user.api_calls_7d}</td>
              <td className="py-3 px-4">
                <StatusBadge is_banned={user.is_banned} is_flagged={user.is_flagged} />
              </td>
              <td className="py-3 px-4">
                <button
                  id={`view-user-${user.id}`}
                  onClick={() => navigate(`/users/${user.id}`)}
                  className="px-3 py-1 rounded-lg bg-indigo-600/20 text-indigo-300 text-xs hover:bg-indigo-600/40 transition-colors"
                >
                  Xem
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
