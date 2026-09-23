import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { supabase } from "../config/supabase";
import { useAuthStore } from "../stores/auth.store";
import { MewmoryLogo } from "../components/Icons";

export default function LoginPage() {
  const navigate = useNavigate();
  const { setUser, setSession, setIsAdmin } = useAuthStore();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e) {
    e.preventDefault();
    setError("");
    setLoading(true);
    try {
      const { data, error: signInError } = await supabase.auth.signInWithPassword({ email, password });
      if (signInError) throw signInError;

      // Check is_admin
      const { data: profile } = await supabase
        .from("profiles")
        .select("is_admin")
        .eq("id", data.user.id)
        .single();

      if (!profile?.is_admin) {
        await supabase.auth.signOut();
        throw new Error("Tài khoản này không có quyền Admin.");
      }

      setUser(data.user);
      setSession(data.session);
      setIsAdmin(true);
      navigate("/dashboard");
    } catch (err) {
      setError(err.message || "Đăng nhập thất bại.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="min-h-screen bg-[#090d16] flex items-center justify-center p-4">
      <div className="w-full max-w-sm">
        {/* Brand header */}
        <div className="text-center mb-8">
          <div className="inline-flex p-3 rounded-2xl bg-blue-600/10 border border-blue-500/20 mb-4 shadow-sm">
            <MewmoryLogo className="w-8 h-8" />
          </div>
          <h1 className="text-xl font-bold tracking-tight text-white">Mewmory Admin</h1>
          <p className="text-xs text-slate-400 mt-1">Cổng quản trị nội bộ hệ thống</p>
        </div>

        {/* Form Container */}
        <div className="bg-[#0f1523] border border-slate-800/80 rounded-2xl p-6 shadow-xl">
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-xs font-medium text-slate-300 mb-1.5 uppercase tracking-wider">
                Địa chỉ Email
              </label>
              <input
                id="admin-email-input"
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                autoFocus
                className="w-full bg-slate-900 border border-slate-700/80 rounded-xl px-3.5 py-2.5 text-white text-sm outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-500 transition-all placeholder:text-slate-500"
                placeholder="admin@mewmory.com"
              />
            </div>

            <div>
              <label className="block text-xs font-medium text-slate-300 mb-1.5 uppercase tracking-wider">
                Mật khẩu
              </label>
              <input
                id="admin-password-input"
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                className="w-full bg-slate-900 border border-slate-700/80 rounded-xl px-3.5 py-2.5 text-white text-sm outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-500 transition-all placeholder:text-slate-500"
                placeholder="••••••••"
              />
            </div>

            {error && (
              <p className="text-rose-400 text-xs bg-rose-500/10 border border-rose-500/20 rounded-xl px-3.5 py-2.5">
                {error}
              </p>
            )}

            <button
              id="admin-login-btn"
              type="submit"
              disabled={loading}
              className="w-full py-2.5 rounded-xl bg-blue-600 text-white text-sm font-medium hover:bg-blue-500 transition-all disabled:opacity-50 disabled:cursor-not-allowed shadow-sm active:scale-[0.99]"
            >
              {loading ? "Đang xác thực quyền Admin..." : "Đăng nhập hệ thống"}
            </button>
          </form>
        </div>

        <p className="text-center text-[11px] text-slate-400 mt-6">
          Chỉ các tài khoản được ủy quyền mới có thể truy cập
        </p>
      </div>
    </div>
  );
}
