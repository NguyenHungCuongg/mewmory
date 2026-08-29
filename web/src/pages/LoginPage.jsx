import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { authService } from "../services/auth.service";
import { useUIStore } from "../stores/ui.store";
import { validateEmail, validatePassword } from "../utils/validators";
import Button from "../components/common/Button";
import Input from "../components/common/Input";

export default function LoginPage() {
  const navigate = useNavigate();
  const addToast = useUIStore((s) => s.addToast);

  const [isSignUp, setIsSignUp] = useState(false);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [errors, setErrors] = useState({});
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    const emailResult = validateEmail(email);
    const passwordResult = validatePassword(password);
    const newErrors = {};
    if (!emailResult.valid) newErrors.email = emailResult.error;
    if (!passwordResult.valid) newErrors.password = passwordResult.error;

    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      return;
    }

    setErrors({});
    setLoading(true);

    try {
      if (isSignUp) {
        const { error } = await authService.signUp(email, password);
        if (error) throw error;
        addToast("Tạo tài khoản thành công!", "success");
      } else {
        const { error } = await authService.signIn(email, password);
        if (error) throw error;
      }
      navigate("/");
    } catch (err) {
      addToast(err.message || "Đã xảy ra lỗi", "error");
    } finally {
      setLoading(false);
    }
  };

  const handleGoogleSignIn = async () => {
    const { error } = await authService.signInWithGoogle();
    if (error) {
      addToast(error.message || "Lỗi đăng nhập Google", "error");
    }
  };

  return (
    <div className="min-h-screen bg-eggshell flex items-center justify-center p-4">
      <div className="w-full max-w-sm">
        {/* Logo */}
        <div className="text-center mb-10">
          <h1 className="text-display font-display font-light tracking-tight">
            Mewmory
          </h1>
          <p className="text-body text-smoke mt-2">
            Ghi chép từ vựng thông minh
          </p>
        </div>

        {/* Form */}
        <div className="bg-warm-taupe rounded-card-lg p-8">
          <h2 className="text-heading-sm font-display font-light mb-6">
            {isSignUp ? "Tạo tài khoản" : "Đăng nhập"}
          </h2>

          <form onSubmit={handleSubmit} className="flex flex-col gap-4">
            <Input
              id="email"
              type="email"
              label="Email"
              placeholder="you@example.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              error={errors.email}
            />
            <Input
              id="password"
              type="password"
              label="Mật khẩu"
              placeholder="••••••"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              error={errors.password}
            />

            <Button type="submit" disabled={loading} className="w-full mt-2">
              {loading
                ? "Đang xử lý..."
                : isSignUp
                  ? "Tạo tài khoản"
                  : "Đăng nhập"}
            </Button>
          </form>

          {/* Divider */}
          <div className="flex items-center gap-3 my-5">
            <div className="flex-1 h-px bg-stone" />
            <span className="text-caption text-ash">hoặc</span>
            <div className="flex-1 h-px bg-stone" />
          </div>

          {/* Google Sign In */}
          <Button
            variant="secondary"
            onClick={handleGoogleSignIn}
            className="w-full"
          >
            Đăng nhập với Google
          </Button>

          {/* Toggle */}
          <p className="text-body-sm text-smoke text-center mt-5">
            {isSignUp ? "Đã có tài khoản?" : "Chưa có tài khoản?"}{" "}
            <button
              type="button"
              onClick={() => {
                setIsSignUp(!isSignUp);
                setErrors({});
              }}
              className="text-ink font-medium hover:underline"
            >
              {isSignUp ? "Đăng nhập" : "Đăng ký"}
            </button>
          </p>
        </div>
      </div>
    </div>
  );
}
