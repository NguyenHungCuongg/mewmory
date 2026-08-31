import { useEffect } from "react";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { useAuthStore } from "./stores/auth.store";
import { useUIStore } from "./stores/ui.store";
import { authService } from "./services/auth.service";
import LoginPage from "./pages/LoginPage";
import AddWordPage from "./pages/AddWordPage";
import VocabularyPage from "./pages/VocabularyPage";
import CollectionsPage from "./pages/CollectionsPage";
import CollectionDetailPage from "./pages/CollectionDetailPage";
import Toast from "./components/common/Toast";
import LoadingSpinner from "./components/common/LoadingSpinner";
import MainLayout from "./components/layout/MainLayout";

function ProtectedRoute({ children }) {
  const { isAuthenticated, isLoading } = useAuthStore();

  if (isLoading) {
    return (
      <div className="min-h-screen bg-eggshell flex items-center justify-center">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  return isAuthenticated ? children : <Navigate to="/login" replace />;
}

function PlaceholderPage({ title }) {
  return (
    <div className="p-8">
      <h1 className="text-heading font-display font-light">{title}</h1>
      <p className="text-smoke mt-2">Coming soon...</p>
    </div>
  );
}

export default function App() {
  const { setUser, setSession, setLoading } = useAuthStore();
  const { toasts, removeToast } = useUIStore();

  useEffect(() => {
    // Check existing session
    authService.getSession().then(({ session }) => {
      setSession(session);
      setUser(session?.user || null);
      setLoading(false);
    });

    // Listen for auth changes
    const {
      data: { subscription },
    } = authService.onAuthStateChange((_event, session) => {
      setSession(session);
      setUser(session?.user || null);
      setLoading(false);
    });

    return () => subscription.unsubscribe();
  }, [setUser, setSession, setLoading]);

  return (
    <BrowserRouter>
      {/* Toast container */}
      {toasts.map((toast) => (
        <Toast
          key={toast.id}
          message={toast.message}
          type={toast.type}
          onClose={() => removeToast(toast.id)}
        />
      ))}

      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route
          element={
            <ProtectedRoute>
              <MainLayout />
            </ProtectedRoute>
          }
        >
          <Route path="/" element={<PlaceholderPage title="Dashboard" />} />
          <Route path="/vocabulary" element={<VocabularyPage />} />
          <Route path="/vocabulary/add" element={<AddWordPage />} />
          <Route
            path="/vocabulary/:id"
            element={<PlaceholderPage title="Word Detail" />}
          />
          <Route path="/collections" element={<CollectionsPage />} />
          <Route
            path="/collections/:id"
            element={<CollectionDetailPage />}
          />
          <Route path="/settings" element={<PlaceholderPage title="Settings" />} />
        </Route>
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </BrowserRouter>
  );
}
