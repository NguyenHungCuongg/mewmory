import { useState } from "react";

export default function BanModal({ onConfirm, onCancel, isLoading }) {
  const [reason, setReason] = useState("");
  const isValid = reason.trim().length >= 10;

  return (
    <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
      <div className="bg-gray-900 border border-white/10 rounded-2xl p-6 w-full max-w-md">
        <h2 className="text-lg font-semibold text-white mb-1">Suspend User</h2>
        <p className="text-sm text-gray-400 mb-4">
          User sẽ không thể gọi API ngay lập tức sau khi bị suspend.
        </p>
        <label className="block text-sm text-gray-300 mb-1">
          Lý do suspend <span className="text-red-400">*</span>
        </label>
        <textarea
          id="ban-reason-input"
          value={reason}
          onChange={(e) => setReason(e.target.value)}
          placeholder="Mô tả lý do suspend (ít nhất 10 ký tự)..."
          rows={3}
          className="w-full bg-white/5 border border-white/10 rounded-xl px-3 py-2 text-white text-sm resize-none outline-none focus:border-indigo-500 transition-colors"
        />
        {reason.length > 0 && !isValid && (
          <p className="text-xs text-red-400 mt-1">Cần ít nhất 10 ký tự.</p>
        )}
        <div className="flex gap-3 mt-4">
          <button
            id="ban-cancel-btn"
            onClick={onCancel}
            disabled={isLoading}
            className="flex-1 py-2 rounded-xl border border-white/10 text-gray-300 text-sm hover:bg-white/5 transition-colors disabled:opacity-50"
          >
            Hủy
          </button>
          <button
            id="ban-confirm-btn"
            onClick={() => isValid && onConfirm(reason.trim())}
            disabled={!isValid || isLoading}
            className="flex-1 py-2 rounded-xl bg-red-600 text-white text-sm font-medium hover:bg-red-700 transition-colors disabled:opacity-40"
          >
            {isLoading ? "Đang xử lý..." : "Xác nhận Suspend"}
          </button>
        </div>
      </div>
    </div>
  );
}
