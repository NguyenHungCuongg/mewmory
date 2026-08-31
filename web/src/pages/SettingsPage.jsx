import { useState, useEffect } from "react";
import { useAuthStore } from "../stores/auth.store";
import { useSettingsStore } from "../stores/settings.store";
import { useCollectionStore } from "../stores/collection.store";
import { useUIStore } from "../stores/ui.store";
import { authService } from "../services/auth.service";
import Header from "../components/layout/Header";
import Button from "../components/common/Button";
import Input from "../components/common/Input";
import LoadingSpinner from "../components/common/LoadingSpinner";
import ConfirmDialog from "../components/common/ConfirmDialog";

export default function SettingsPage() {
  const { user, signOut } = useAuthStore();
  const { settings, isLoading, fetchSettings, updateSettings } = useSettingsStore();
  const { items: collections, fetchCollections } = useCollectionStore();
  const addToast = useUIStore((s) => s.addToast);

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
      addToast("Đã lưu cài đặt thành công!", "success");
    } catch (err) {
      addToast(err.message || "Lỗi lưu cài đặt", "error");
    } finally {
      setIsSaving(false);
    }
  };

  const handleSignOut = async () => {
    try {
      await authService.signOut();
      signOut();
      addToast("Đã đăng xuất", "info");
    } catch (err) {
      addToast(err.message || "Lỗi đăng xuất", "error");
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
      <Header title="Cài đặt hệ thống (Settings)" />

      <div className="p-6 max-w-3xl mx-auto">
        <form onSubmit={handleSave} className="flex flex-col gap-8">
          {/* AI Configuration */}
          <div className="card-taupe flex flex-col gap-4">
            <div>
              <h3 className="text-subheading font-display font-light text-ink">
                🤖 Cấu hình AI & Tra cứu
              </h3>
              <p className="text-body-sm text-smoke mt-1">
                Tùy chỉnh nhà cung cấp mô hình trí tuệ nhân tạo dùng để bóc tách từ và phân loại.
              </p>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div className="flex flex-col gap-1.5">
                <label className="text-body-sm text-graphite font-medium">
                  AI Provider
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
                          : "meta-llama/llama-3.1-8b-instruct:free",
                    })
                  }
                  className="w-full px-3 py-2 rounded-lg border border-stone bg-eggshell text-body text-graphite focus:outline-none focus:border-ink"
                >
                  <option value="gemini">Google Gemini (Khuyên dùng)</option>
                  <option value="openrouter">OpenRouter AI</option>
                </select>
              </div>

              <Input
                id="ai-model"
                label="Model Name"
                value={formData.ai_model}
                onChange={(e) =>
                  setFormData({ ...formData, ai_model: e.target.value })
                }
              />
            </div>
          </div>

          {/* Daily Review & Notifications */}
          <div className="card-taupe flex flex-col gap-4">
            <div>
              <h3 className="text-subheading font-display font-light text-ink">
                🔔 Nhắc nhở & Ôn tập hàng ngày
              </h3>
              <p className="text-body-sm text-smoke mt-1">
                Thiết lập chế độ hiển thị thẻ flashcard và lịch ôn tập từ vựng.
              </p>
            </div>

            <div className="flex items-center justify-between p-3 bg-eggshell rounded-lg border border-stone">
              <div>
                <span className="text-body-sm font-medium text-ink">
                  Kích hoạt nhắc nhở định kỳ
                </span>
                <p className="text-caption text-smoke">
                  Hiển thị thông báo ôn từ vựng theo giờ đã chọn
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
                  Chế độ ôn tập mặc định
                </label>
                <select
                  value={formData.notification_mode}
                  onChange={(e) =>
                    setFormData({
                      ...formData,
                      notification_mode: e.target.value,
                    })
                  }
                  className="w-full px-3 py-2 rounded-lg border border-stone bg-eggshell text-body text-graphite focus:outline-none focus:border-ink"
                >
                  <option value="gentle">Xem nhanh (Gentle mode)</option>
                  <option value="quiz">Quiz kiểm tra (Ẩn nghĩa)</option>
                </select>
              </div>

              <div className="flex flex-col gap-1.5">
                <label className="text-body-sm text-graphite font-medium">
                  Thời gian nhắc nhở
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
                  className="w-full px-3 py-2 rounded-lg border border-stone bg-eggshell text-body text-graphite focus:outline-none focus:border-ink"
                />
              </div>
            </div>

            {/* Collection source */}
            {collections.length > 0 && (
              <div className="flex flex-col gap-2 mt-2">
                <label className="text-body-sm text-graphite font-medium">
                  Ưu tiên ôn tập từ các bộ sưu tập:
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
                        className={`px-3 py-1 rounded-pill text-body-sm transition-all ${
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
                👤 Tài khoản & Bảo mật
              </h3>
            </div>

            <div className="flex flex-col gap-2 text-body-sm">
              <div className="flex justify-between py-2 border-b border-stone">
                <span className="text-smoke">Email đăng nhập:</span>
                <span className="font-medium text-ink">{user?.email}</span>
              </div>
              <div className="flex justify-between py-2 border-b border-stone">
                <span className="text-smoke">User ID:</span>
                <span className="font-mono text-ash text-caption">{user?.id}</span>
              </div>
            </div>

            <div className="flex justify-start pt-2">
              <Button
                type="button"
                variant="secondary"
                onClick={() => setShowSignOutConfirm(true)}
                className="text-red-600 hover:text-red-800"
              >
                Đăng xuất tài khoản
              </Button>
            </div>
          </div>

          {/* Save Button Bar */}
          <div className="flex items-center justify-end gap-4 pt-4 border-t border-stone">
            <Button type="submit" disabled={isSaving}>
              {isSaving ? "Đang lưu cài đặt..." : "Lưu tất cả thay đổi"}
            </Button>
          </div>
        </form>
      </div>

      <ConfirmDialog
        isOpen={showSignOutConfirm}
        title="Xác nhận đăng xuất"
        message="Bạn có chắc chắn muốn đăng xuất khỏi tài khoản Mewmory trên thiết bị này không?"
        confirmText="Đăng xuất"
        variant="danger"
        onConfirm={handleSignOut}
        onCancel={() => setShowSignOutConfirm(false)}
      />
    </>
  );
}
