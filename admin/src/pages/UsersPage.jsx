import { useEffect, useState } from "react";
import { adminService } from "../services/admin.service";
import AdminLayout from "../components/AdminLayout";
import UserTable from "../components/UserTable";
import { SearchIcon } from "../components/Icons";

const FILTERS = [
  { key: "all", label: "Tất cả" },
  { key: "active", label: "Đang hoạt động" },
  { key: "flagged", label: "Cần rà soát" },
  { key: "banned", label: "Đã khóa" },
];

export default function UsersPage() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [search, setSearch] = useState("");
  const [filter, setFilter] = useState("all");
  const [page, setPage] = useState(0);
  const PAGE_SIZE = 15;

  useEffect(() => {
    adminService
      .listUsers()
      .then(setUsers)
      .catch((err) => setError(err.message))
      .finally(() => setLoading(false));
  }, []);

  const counts = {
    all: users.length,
    active: users.filter((u) => !u.is_banned && !u.is_flagged).length,
    flagged: users.filter((u) => u.is_flagged && !u.is_banned).length,
    banned: users.filter((u) => u.is_banned).length,
  };

  const filtered = users.filter((u) => {
    const matchSearch =
      !search ||
      u.email.toLowerCase().includes(search.toLowerCase()) ||
      (u.display_name || "").toLowerCase().includes(search.toLowerCase());

    const matchFilter =
      filter === "all" ||
      (filter === "active" && !u.is_banned && !u.is_flagged) ||
      (filter === "flagged" && u.is_flagged && !u.is_banned) ||
      (filter === "banned" && u.is_banned);

    return matchSearch && matchFilter;
  });

  const paginated = filtered.slice(page * PAGE_SIZE, (page + 1) * PAGE_SIZE);
  const totalPages = Math.ceil(filtered.length / PAGE_SIZE);

  return (
    <AdminLayout
      title="Quản lý người dùng"
      subtitle="Theo dõi thành viên, lưu lượng sử dụng và trạng thái kiểm duyệt"
    >
      <div className="space-y-6 max-w-7xl">
        {error && (
          <div className="p-4 rounded-xl bg-rose-500/10 border border-rose-500/20 text-rose-400 text-sm">
            {error}
          </div>
        )}

        {/* Filter Bar & Search */}
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
          {/* Sub-tabs */}
          <div className="flex items-center gap-1.5 p-1 rounded-xl bg-[#0f1523] border border-slate-800/80">
            {FILTERS.map((f) => {
              const count = counts[f.key] || 0;
              const isActive = filter === f.key;
              return (
                <button
                  key={f.key}
                  id={`filter-${f.key}`}
                  onClick={() => {
                    setFilter(f.key);
                    setPage(0);
                  }}
                  className={`flex items-center gap-2 px-3 py-1.5 rounded-lg text-xs font-medium transition-all ${
                    isActive
                      ? "bg-blue-600 text-white shadow-sm"
                      : "text-slate-400 hover:text-slate-200 hover:bg-slate-800/50"
                  }`}
                >
                  <span>{f.label}</span>
                  <span
                    className={`px-1.5 py-0.2 rounded-full text-[10px] font-mono tabular-nums ${
                      isActive ? "bg-white/20 text-white" : "bg-slate-800 text-slate-400"
                    }`}
                  >
                    {count}
                  </span>
                </button>
              );
            })}
          </div>

          {/* Search box */}
          <div className="relative w-full md:w-80">
            <SearchIcon className="w-4 h-4 text-slate-500 absolute left-3.5 top-1/2 -translate-y-1/2 pointer-events-none" />
            <input
              id="user-search-input"
              type="text"
              value={search}
              onChange={(e) => {
                setSearch(e.target.value);
                setPage(0);
              }}
              placeholder="Tìm theo email hoặc tên..."
              className="w-full pl-9.5 pr-4 py-2 bg-[#0f1523] border border-slate-800/80 rounded-xl text-white text-xs outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-500 transition-all placeholder:text-slate-500"
            />
          </div>
        </div>

        {/* Users Table Container */}
        <div className="bg-[#0f1523] border border-slate-800/80 rounded-2xl overflow-hidden shadow-sm">
          {loading ? (
            <div className="flex flex-col items-center justify-center py-20 gap-3">
              <div className="w-8 h-8 border-2 border-blue-500 border-t-transparent rounded-full animate-spin" />
              <span className="text-xs text-slate-400">Đang tải danh sách người dùng...</span>
            </div>
          ) : (
            <>
              <UserTable users={paginated} />

              {/* Pagination */}
              {totalPages > 1 && (
                <div className="flex items-center justify-between px-6 py-3.5 border-t border-slate-800/80 bg-slate-900/20 text-xs text-slate-400">
                  <span>
                    Hiển thị <span className="font-mono text-slate-200">{filtered.length}</span> người dùng · Trang{" "}
                    <span className="font-mono text-slate-200">{page + 1}</span> / {totalPages}
                  </span>

                  <div className="flex items-center gap-2">
                    <button
                      id="prev-page-btn"
                      onClick={() => setPage((p) => Math.max(0, p - 1))}
                      disabled={page === 0}
                      className="px-3 py-1.5 rounded-lg border border-slate-700/80 bg-slate-800/50 text-slate-300 font-medium hover:bg-slate-700/60 disabled:opacity-30 disabled:pointer-events-none transition-all"
                    >
                      ← Trang trước
                    </button>
                    <button
                      id="next-page-btn"
                      onClick={() => setPage((p) => Math.min(totalPages - 1, p + 1))}
                      disabled={page >= totalPages - 1}
                      className="px-3 py-1.5 rounded-lg border border-slate-700/80 bg-slate-800/50 text-slate-300 font-medium hover:bg-slate-700/60 disabled:opacity-30 disabled:pointer-events-none transition-all"
                    >
                      Trang sau →
                    </button>
                  </div>
                </div>
              )}
            </>
          )}
        </div>
      </div>
    </AdminLayout>
  );
}
