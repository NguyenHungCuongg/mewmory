import { useEffect } from "react";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { useAuthStore } from "./stores/auth.store";
import { supabase } from "./config/supabase";
import LoginPage from "./pages/LoginPage";
import DashboardPage from "./pages/DashboardPage";
import UsersPage from "./pages/UsersPage";
import UserDetailPage from "./pages/UserDetailPage";

function AdminRoute({ children }) {
  const { isAdmin, isLoading } = useAuthStore();
  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[#090d16]">
        <div className="w-8 h-8 border-2 border-blue-500 border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }
  return isAdmin ? children : <Navigate to="/login" replace />;
}

export default function App() {
  const { setUser, setSession, setLoading, setIsAdmin, signOut } = useAuthStore();

  useEffect(() => {
    supabase.auth.getSession().then(async ({ data: { session } }) => {
      setSession(session);
      setUser(session?.user ?? null);
      if (session?.user) {
        // Check is_admin from profiles
        const { data } = await supabase
          .from("profiles")
          .select("is_admin")
          .eq("id", session.user.id)
          .single();
        if (data?.is_admin) {
          setIsAdmin(true);
        } else {
          // Logged in but not admin — sign out
          await supabase.auth.signOut();
          signOut();
        }
      }
      setLoading(false);
    });

    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (_event, session) => {
        setSession(session);
        setUser(session?.user ?? null);
        if (!session) {
          signOut();
          setLoading(false);
        }
      }
    );
    return () => subscription.unsubscribe();
  }, [setUser, setSession, setLoading, setIsAdmin, signOut]);

  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route
          path="/dashboard"
          element={<AdminRoute><DashboardPage /></AdminRoute>}
        />
        <Route
          path="/users"
          element={<AdminRoute><UsersPage /></AdminRoute>}
        />
        <Route
          path="/users/:userId"
          element={<AdminRoute><UserDetailPage /></AdminRoute>}
        />
        <Route path="/" element={<Navigate to="/dashboard" replace />} />
        <Route path="*" element={<Navigate to="/dashboard" replace />} />
      </Routes>
    </BrowserRouter>
  );
}
