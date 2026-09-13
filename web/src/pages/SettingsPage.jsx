import { useState, useEffect } from "react";
import { useTranslation } from "react-i18next";
import { useAuthStore } from "../stores/auth.store";
import { useSettingsStore } from "../stores/settings.store";
import { useCollectionStore } from "../stores/collection.store";
import { useUIStore } from "../stores/ui.store";
import { useThemeStore } from "../stores/theme.store";
import { authService } from "../services/auth.service";
import Header from "../components/layout/Header";
import Button from "../components/common/Button";
import Input from "../components/common/Input";
import LoadingSpinner from "../components/common/LoadingSpinner";
import ConfirmDialog from "../components/common/ConfirmDialog";
import { IconSun, IconMoon, IconMonitor } from "../components/common/Icons";

export default function SettingsPage() {
  const { t } = useTranslation("settings");
  const { user, signOut } = useAuthStore();
  const { settings, isLoading, fetchSettings, updateSettings } = useSettingsStore();
  const { items: collections, fetchCollections } = useCollectionStore();
  const addToast = useUIStore((s) => s.addToast);
  const { theme, setTheme } = useThemeStore();

  const [formData, setFormData] = useState({
    ai_provider: "gemini",
    ai_model: "gemini-3.6-flash",
    notification_enabled: false,
    notification_mode: "gentle",
    notification_time: "09:00",
    notification_collection_ids: [],
  });

  const [isSaving, setIsSaving] = useState(false);
  const [showSignOutConfirm, setShowSignOutConfirm] = useState(false);

  useEffect(() => {
    if (user) {
      fetchSettings(user.id);
      fetchCollections(user.id);
    }
  }, [user, fetchSettings, fetchCollections]);

  useEffect(() => {
    if (settings) {
      setFormData({
        ai_provider: settings.ai_provider || "gemini",
        ai_model: settings.ai_model || "gemini-3.6-flash",
        notification_enabled: !!settings.notification_enabled,
        notification_mode: settings.notification_mode || "gentle",
        notification_time: settings.notification_time?.substring(0, 5) || "09:00",
        notification_collection_ids: settings.notification_collection_ids || [],
      });
    }
  }, [settings]);

  const handleToggleCollection = (colId) => {
    setFormData((prev) => {
      const exists = prev.notification_collection_ids.includes(colId);
      return {
        ...prev,
        notification_collection_ids: exists
          ? prev.notification_collection_ids.filter((id) => id !== colId)
          : [...prev.notification_collection_ids, colId],
      };
    });
  };

  const handleSave = async (e) => {
    e.preventDefault();
    if (!user) return;

    setIsSaving(true);
    try {
      await updateSettings(user.id, {
        ...formData,
        notification_time: `${formData.notification_time}:00`,
      });
      addToast(t("saveSuccess"), "success");
    } catch (err) {
      addToast(err.message || t("saveError"), "error");
    } finally {
      setIsSaving(false);
    }
  };

  const handleSignOut = async () => {
    try {
      await authService.signOut();
      signOut();
      addToast(t("signOutSuccess"), "info");
    } catch (err) {
      addToast(err.message || t("signOutError"), "error");
    }
  };

  if (isLoading && !settings) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  return (
    <>
      <Header title={t("title")} />

      <div className="p-6 max-w-3xl mx-auto">
        <form onSubmit={handleSave} className="flex flex-col gap-8">
          {/* Appearance / Theme */}
          <div className="card-taupe flex flex-col gap-4">
            <div>
              <h3 className="text-subheading font-display font-light text-ink">
                {t("appearance.title")}
              </h3>
              <p className="text-body-sm text-smoke mt-1">
                {t("appearance.description")}
              </p>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
              {[
                { value: "light", icon: IconSun, label: t("appearance.light"), desc: t("appearance.lightDesc") },
                { value: "dark", icon: IconMoon, label: t("appearance.dark"), desc: t("appearance.darkDesc") },
                { value: "system", icon: IconMonitor, label: t("appearance.system"), desc: t("appearance.systemDesc") },
              ].map((opt) => {
                const Icon = opt.icon;
                return (
                  <button
                    key={opt.value}
                    type="button"
                    onClick={() => setTheme(opt.value)}
                    className={`flex flex-col items-center text-center gap-2 p-4 rounded-xl border transition-all cursor-pointer ${
                      theme === opt.value
                        ? "bg-eggshell border-ink ring-2 ring-ink text-ink font-medium shadow-sm"
                        : "bg-eggshell/40 border-stone text-smoke hover:text-ink hover:border-graphite/40"
                    }`}
                  >
                    <div className="w-8 h-8 rounded-full bg-stone/30 flex items-center justify-center">
                      <Icon className="w-4 h-4 text-current" />
                    </div>
                    <span className="text-body-sm font-medium">{opt.label}</span>
                    <span className="text-caption text-ash">{opt.desc}</span>
                  </button>
                );
              })}
            </div>
          </div>

          {/* AI Configuration */}
          <div className="card-taupe flex flex-col gap-4">
            <div>
              <h3 className="text-subheading font-display font-light text-ink">
                {t("ai.title")}
              </h3>
              <p className="text-body-sm text-smoke mt-1">
                {t("ai.description")}
              </p>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div className="flex flex-col gap-1.5">
                <label className="text-body-sm text-graphite font-medium">
                  {t("ai.provider")}
                </label>
                <select
                  value={formData.ai_provider}
                  onChange={(e) =>
                    setFormData({
                      ...formData,
                      ai_provider: e.target.value,
                      ai_model:
                        e.target.value === "gemini"
                          ? "gemini-3.6-flash"
                          : "google/gemma-4-31b-it:free",
                    })
                  }
                  className="w-full px-3 py-2 rounded-lg border border-stone bg-eggshell text-body text-graphite focus:outline-none focus:border-ink cursor-pointer"
                >
                  <option value="gemini">Google Gemini</option>
                  <option value="openrouter">OpenRouter AI (Miễn phí & Đa dạng)</option>
                </select>
              </div>

              <div className="flex flex-col gap-1.5">
                <Input
                  id="ai-model"
                  label={t("ai.modelName")}
                  value={formData.ai_model}
                  onChange={(e) =>
                    setFormData({ ...formData, ai_model: e.target.value })
                  }
                />
              </div>
            </div>

            {formData.ai_provider === "openrouter" && (
              <div className="p-3 bg-warm-taupe/40 rounded-lg border border-stone flex flex-col gap-2">
                <div className="flex items-center justify-between flex-wrap gap-1">
                  <span className="text-caption font-medium text-graphite">
                    {t("ai.openrouterTip")}
                  </span>
                  <span className="text-caption text-ash">
                    {t("ai.apiKeyNote")}
                  </span>
                </div>
                <div className="flex flex-wrap gap-2">
                  <button
                    type="button"
                    onClick={() =>
                      setFormData({
                        ...formData,
                        ai_model: "google/gemma-4-31b-it:free",
                      })
                    }
                    className={`text-caption px-2.5 py-1 rounded-pill border transition-colors cursor-pointer ${
                      formData.ai_model ===
                      "google/gemma-4-31b-it:free"
                        ? "bg-ink text-eggshell border-ink font-medium"
                        : "bg-eggshell text-smoke border-stone hover:text-ink hover:border-graphite"
                    }`}
                  >
                    {t("ai.gemmaRecommend")}
                  </button>
                </div>
              </div>
            )}
          </div>

          {/* Daily Review & Notifications */}
          <div className="card-taupe flex flex-col gap-4">
            <div>
              <h3 className="text-subheading font-display font-light text-ink">
                {t("notifications.title")}
              </h3>
              <p className="text-body-sm text-smoke mt-1">
                {t("notifications.description")}
              </p>
            </div>

            <div className="flex items-center justify-between p-3 bg-eggshell rounded-lg border border-stone">
              <div>
                <span className="text-body-sm font-medium text-ink">
                  {t("notifications.enable")}
                </span>
                <p className="text-caption text-smoke">
                  {t("notifications.enableDesc")}
                </p>
              </div>
              <input
                type="checkbox"
                checked={formData.notification_enabled}
                onChange={(e) =>
                  setFormData({
                    ...formData,
                    notification_enabled: e.target.checked,
                  })
                }
                className="w-5 h-5 accent-ink cursor-pointer"
              />
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div className="flex flex-col gap-1.5">
                <label className="text-body-sm text-graphite font-medium">
                  {t("notifications.defaultMode")}
                </label>
                <select
                  value={formData.notification_mode}
                  onChange={(e) =>
                    setFormData({
                      ...formData,
                      notification_mode: e.target.value,
                    })
                  }
                  className="w-full px-3 py-2 rounded-lg border border-stone bg-eggshell text-body text-graphite focus:outline-none focus:border-ink cursor-pointer"
                >
                  <option value="gentle">{t("notifications.gentleMode")}</option>
                  <option value="quiz">{t("notifications.quizMode")}</option>
                </select>
              </div>

              <div className="flex flex-col gap-1.5">
                <label className="text-body-sm text-graphite font-medium">
                  {t("notifications.time")}
                </label>
                <input
                  type="time"
                  value={formData.notification_time}
                  onChange={(e) =>
                    setFormData({
                      ...formData,
                      notification_time: e.target.value,
                    })
                  }
                  className="w-full px-3 py-2 rounded-lg border border-stone bg-eggshell text-body text-graphite focus:outline-none focus:border-ink cursor-pointer"
                />
              </div>
            </div>

            {/* Collection source */}
            {collections.length > 0 && (
              <div className="flex flex-col gap-2 mt-2">
                <label className="text-body-sm text-graphite font-medium">
                  {t("notifications.collectionPriority")}
                </label>
                <div className="flex flex-wrap gap-2">
                  {collections.map((col) => {
                    const isSelected =
                      formData.notification_collection_ids.includes(col.id);
                    return (
                      <button
                        key={col.id}
                        type="button"
                        onClick={() => handleToggleCollection(col.id)}
                        className={`px-3 py-1 rounded-pill text-body-sm transition-all cursor-pointer ${
                          isSelected
                            ? "bg-ink text-eggshell font-medium"
                            : "bg-eggshell text-smoke border border-stone hover:border-graphite/40"
                        }`}
                      >
                        {isSelected ? "✓ " : "+ "}
                        {col.name}
                      </button>
                    );
                  })}
                </div>
              </div>
            )}
          </div>

          {/* Account Management */}
          <div className="card-taupe flex flex-col gap-4">
            <div>
              <h3 className="text-subheading font-display font-light text-ink">
                {t("account.title")}
              </h3>
            </div>

            <div className="flex flex-col gap-2 text-body-sm">
              <div className="flex justify-between py-2 border-b border-stone">
                <span className="text-smoke">{t("account.email")}</span>
                <span className="font-medium text-ink">{user?.email}</span>
              </div>
              <div className="flex justify-between py-2 border-b border-stone">
                <span className="text-smoke">{t("account.userId")}</span>
                <span className="font-mono text-ash text-caption">{user?.id}</span>
              </div>
            </div>

            <div className="flex justify-start pt-2">
              <Button
                type="button"
                variant="secondary"
                onClick={() => setShowSignOutConfirm(true)}
                className="text-red-600 hover:text-red-800 dark:text-red-400 dark:hover:text-red-300 cursor-pointer"
              >
                {t("account.signOut")}
              </Button>
            </div>
          </div>

          {/* About Mewmory */}
          <div className="card-taupe flex items-center gap-4">
            <img
              src="/mewmory_icon_192.png"
              alt="Mewmory Logo"
              className="w-12 h-12 rounded-2xl shadow-subtle object-contain shrink-0"
            />
            <div>
              <div className="flex items-center gap-2">
                <h4 className="font-display font-medium text-ink text-body">
                  Mewmory
                </h4>
                <span className="text-[11px] font-mono px-2 py-0.5 rounded-full bg-stone text-smoke">
                  v1.0.0
                </span>
              </div>
              <p className="text-caption text-smoke mt-0.5">
                {t("about.tagline")}
              </p>
            </div>
          </div>

          {/* Save Button Bar */}
          <div className="flex items-center justify-end gap-4 pt-4 border-t border-stone">
            <Button type="submit" disabled={isSaving}>
              {isSaving ? t("saving") : t("saveAll")}
            </Button>
          </div>
        </form>
      </div>

      <ConfirmDialog
        isOpen={showSignOutConfirm}
        title={t("account.signOutConfirmTitle")}
        message={t("account.signOutConfirmMessage")}
        confirmText={t("account.signOutButton")}
        variant="danger"
        onConfirm={handleSignOut}
        onCancel={() => setShowSignOutConfirm(false)}
      />
    </>
  );
}

