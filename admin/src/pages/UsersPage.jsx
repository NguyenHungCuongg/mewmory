import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { adminService } from "../services/admin.service";
import { supabase } from "../config/supabase";
import { useAuthStore } from "../stores/auth.store";
import UserTable from "../components/UserTable";

const FILTERS = ["Tất cả", "Active", "Flagged", "Banned"];

export default function UsersPage() {
  const navigate = useNavigate();
  const { signOut } = useAuthStore();
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [search, setSearch] = useState("");
  const [filter, setFilter] = useState("Tất cả");
  const [page, setPage] = useState(0);
  const PAGE_SIZE = 20;

  useEffect(() => {
    adminService
      .listUsers()
      .then(setUsers)
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false));
  }, []);

  async function handleSignOut() {
    await supabase.auth.signOut();
    signOut();
    navigate("/login");
  }

  const filtered = users.filter((u) => {
    const matchSearch =
      !search ||
      u.email.toLowerCase().includes(search.toLowerCase()) ||
      (u.display_name || "").toLowerCase().includes(search.toLowerCase());
    const matchFilter =
      filter === "Tất cả" ||
      (filter === "Active" && !u.is_banned && !u.is_flagged) ||
      (filter === "Flagged" && u.is_flagged && !u.is_banned) ||
      (filter === "Banned" && u.is_banned);
    return matchSearch && matchFilter;
  });

  const paginated = filtered.slice(page * PAGE_SIZE, (page + 1) * PAGE_SIZE);
  const totalPages = Math.ceil(filtered.length / PAGE_SIZE);

  return (
    <div className="min-h-screen bg-gray-950 text-white">
      <header className="border-b border-white/10 px-6 py-4 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <span className="text-xl">🐱</span>
          <span className="font-semibold">Mewmory Admin</span>
        </div>
        <nav className="flex items-center gap-4">
          <button onClick={() => navigate("/dashboard")} className="text-sm text-gray-400 hover:text-white">Dashboard</button>
          <button onClick={() => navigate("/users")} className="text-sm text-indigo-400">Users</button>
          <button onClick={handleSignOut} className="text-sm text-gray-500 hover:text-red-400 transition-colors">Đăng xuất</button>
        </nav>
      </header>

      <main className="max-w-6xl mx-auto px-6 py-8">
        <h1 className="text-2xl font-semibold mb-6">Quản lý Users</h1>

        {error && (
          <div className="mb-4 p-4 rounded-xl bg-red-950/30 border border-red-500/20 text-red-400 text-sm">{error}</div>
        )}

        {/* Controls */}
        <div className="flex flex-col sm:flex-row gap-3 mb-6">
          <input
            id="user-search-input"
            type="text"
            value={search}
            onChange={(e) => { setSearch(e.target.value); setPage(0); }}
            placeholder="Tìm theo email hoặc tên..."
            className="flex-1 bg-white/5 border border-white/10 rounded-xl px-4 py-2 text-white text-sm outline-none focus:border-indigo-500 transition-colors"
          />
          <div className="flex gap-2">
            {FILTERS.map((f) => (
              <button
                key={f}
                id={`filter-${f}`}
                onClick={() => { setFilter(f); setPage(0); }}
                className={`px-3 py-1.5 rounded-xl text-xs font-medium transition-colors ${
                  filter === f
                    ? "bg-indigo-600 text-white"
                    : "bg-white/5 text-gray-400 hover:bg-white/10"
                }`}
              >
                {f}
              </button>
            ))}
          </div>
        </div>

        {loading ? (
          <div className="flex justify-center py-16">
            <div className="w-8 h-8 border-2 border-indigo-500 border-t-transparent rounded-full animate-spin" />
          </div>
        ) : (
          <div className="bg-white/5 border border-white/10 rounded-2xl overflow-hidden">
            <UserTable users={paginated} />
            {totalPages > 1 && (
              <div className="flex items-center justify-between px-4 py-3 border-t border-white/10">
                <span className="text-sm text-gray-400">
                  {filtered.length} users · Trang {page + 1}/{totalPages}
                </span>
                <div className="flex gap-2">
                  <button
                    id="prev-page-btn"
                    onClick={() => setPage((p) => Math.max(0, p - 1))}
                    disabled={page === 0}
                    className="px-3 py-1 rounded-lg text-sm bg-white/5 text-gray-400 disabled:opacity-30 hover:bg-white/10 transition-colors"
                  >
                    ← Trước
                  </button>
                  <button
                    id="next-page-btn"
                    onClick={() => setPage((p) => Math.min(totalPages - 1, p + 1))}
                    disabled={page >= totalPages - 1}
                    className="px-3 py-1 rounded-lg text-sm bg-white/5 text-gray-400 disabled:opacity-30 hover:bg-white/10 transition-colors"
                  >
                    Tiếp →
                  </button>
                </div>
              </div>
            )}
          </div>
        )}
      </main>
    </div>
  );
}
