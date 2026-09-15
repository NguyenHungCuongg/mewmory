import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { authService } from "../services/auth.service";
import { useUIStore } from "../stores/ui.store";
import { validateEmail, validatePassword } from "../utils/validators";
import { getAuthErrorMessage } from "../utils/authErrors";
import Button from "../components/common/Button";
import Input from "../components/common/Input";
import LanguageSwitcher from "../components/common/LanguageSwitcher";

export default function LoginPage() {
  const navigate = useNavigate();
  const { t } = useTranslation("auth");
  const addToast = useUIStore((s) => s.addToast);

  const [isSignUp, setIsSignUp] = useState(false);
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [errors, setErrors] = useState({});
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    const emailResult = validateEmail(email);
    const passwordResult = validatePassword(password);
    const newErrors = {};
    if (!emailResult.valid) newErrors.email = emailResult.error;
    if (!passwordResult.valid) newErrors.password = passwordResult.error;

    if (isSignUp) {
      if (!confirmPassword) {
        newErrors.confirmPassword = t("confirmPasswordRequired");
      } else if (password !== confirmPassword) {
        newErrors.confirmPassword = t("passwordMismatch");
      }
    }

    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      return;
    }

    setErrors({});
    setLoading(true);

    try {
      if (isSignUp) {
        const { session, error } = await authService.signUp(email, password);
        if (error) throw error;

        if (!session) {
          addToast(
            t("signUpSuccessNotice"),
            "info",
          );
          setIsSignUp(false);
          setPassword("");
          setConfirmPassword("");
        } else {
          addToast(t("signUpSuccess"), "success");
          navigate("/");
        }
      } else {
        const { error } = await authService.signIn(email, password);
        if (error) throw error;
        navigate("/");
      }
    } catch (err) {
      const msg = getAuthErrorMessage(err);
      addToast(msg, "error");
      if (
        err?.code === "user_already_exists" ||
        msg.includes("đã được đăng ký")
      ) {
        setIsSignUp(false);
        setPassword("");
        setConfirmPassword("");
      }
    } finally {
      setLoading(false);
    }
  };

  const handleGoogleSignIn = async () => {
    const { error } = await authService.signInWithGoogle();
    if (error) {
      addToast(getAuthErrorMessage(error), "error");
    }
  };

  return (
    <div className="min-h-screen bg-eggshell flex flex-col items-center justify-center p-4 relative">
      <div className="absolute top-4 right-4">
        <LanguageSwitcher />
      </div>

      <div className="w-full max-w-sm">
        {/* Logo */}
        <div className="text-center mb-8 flex flex-col items-center">
          <img
            src="/mewmory_icon_192.png"
            alt="Mewmory Logo"
            className="w-16 h-16 rounded-2xl shadow-subtle mb-4 object-contain"
          />
          <h1 className="text-display font-display font-light tracking-tight">
            Mewmory
          </h1>
          <p className="text-body text-smoke mt-2">
            {t("tagline")}
          </p>
        </div>

        {/* Form */}
        <div className="bg-warm-taupe rounded-card-lg p-8">
          <h2 className="text-heading-sm font-display font-light mb-6">
            {isSignUp ? t("signUp") : t("signIn")}
          </h2>

          <form onSubmit={handleSubmit} className="flex flex-col gap-4">
            <Input
              id="email"
              type="email"
              label={t("email")}
              placeholder="you@example.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              error={errors.email}
            />
            <Input
              id="password"
              type="password"
              label={t("password")}
              placeholder="••••••"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              error={errors.password}
            />
            {isSignUp && (
              <Input
                id="confirm-password"
                type="password"
                label={t("confirmPassword")}
                placeholder="••••••"
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                error={errors.confirmPassword}
              />
            )}

            <Button type="submit" disabled={loading} className="w-full mt-2">
              {loading
                ? t("processing")
                : isSignUp
                  ? t("signUp")
                  : t("signIn")}
            </Button>
          </form>

          {/* Divider */}
          <div className="flex items-center gap-3 my-5">
            <div className="flex-1 h-px bg-stone" />
            <span className="text-caption text-ash">{t("or")}</span>
            <div className="flex-1 h-px bg-stone" />
          </div>

          {/* Google Sign In */}
          <Button
            variant="secondary"
            onClick={handleGoogleSignIn}
            className="w-full"
          >
            {t("signInWithGoogle")}
          </Button>

          {/* Toggle */}
          <p className="text-body-sm text-smoke text-center mt-5">
            {isSignUp ? t("hasAccount") : t("noAccount")}{" "}
            <button
              type="button"
              onClick={() => {
                setIsSignUp(!isSignUp);
                setPassword("");
                setConfirmPassword("");
                setErrors({});
              }}
              className="text-ink font-medium hover:underline cursor-pointer"
            >
              {isSignUp ? t("toggleToSignIn") : t("toggleToSignUp")}
            </button>
          </p>
        </div>
      </div>
    </div>
  );
}

