import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { supabase } from "../config/supabase";
import { useAuthStore } from "../stores/auth.store";

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
    <div className="min-h-screen bg-gray-950 flex items-center justify-center p-4">
      <div className="w-full max-w-sm">
        <div className="text-center mb-8">
          <div className="text-4xl mb-3">🐱</div>
          <h1 className="text-2xl font-semibold text-white">Mewmory Admin</h1>
          <p className="text-gray-400 text-sm mt-1">Internal dashboard</p>
        </div>
        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm text-gray-300 mb-1.5">Email</label>
            <input
              id="admin-email-input"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              autoFocus
              className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-2.5 text-white text-sm outline-none focus:border-indigo-500 transition-colors"
              placeholder="admin@example.com"
            />
          </div>
          <div>
            <label className="block text-sm text-gray-300 mb-1.5">Mật khẩu</label>
            <input
              id="admin-password-input"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              className="w-full bg-white/5 border border-white/10 rounded-xl px-4 py-2.5 text-white text-sm outline-none focus:border-indigo-500 transition-colors"
              placeholder="••••••••"
            />
          </div>
          {error && (
            <p className="text-red-400 text-sm bg-red-950/30 border border-red-500/20 rounded-xl px-4 py-2.5">
              {error}
            </p>
          )}
          <button
            id="admin-login-btn"
            type="submit"
            disabled={loading}
            className="w-full py-2.5 rounded-xl bg-indigo-600 text-white font-medium hover:bg-indigo-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {loading ? "Đang đăng nhập..." : "Đăng nhập"}
          </button>
        </form>
      </div>
    </div>
  );
}
