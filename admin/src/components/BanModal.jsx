import { useState } from "react";
import { ShieldAlertIcon } from "./Icons";

export default function BanModal({ onConfirm, onCancel, isLoading }) {
  const [reason, setReason] = useState("");
  const isValid = reason.trim().length >= 10;

  return (
    <div className="fixed inset-0 bg-black/75 backdrop-blur-sm flex items-center justify-center z-50 p-4 animate-in fade-in duration-200">
      <div className="bg-[#0f1523] border border-slate-700/80 rounded-2xl p-6 w-full max-w-md shadow-2xl">
        <div className="flex items-center gap-3 mb-3">
          <div className="p-2.5 rounded-xl bg-rose-500/10 border border-rose-500/20 text-rose-400">
            <ShieldAlertIcon className="w-5 h-5" />
          </div>
          <div>
            <h2 className="text-base font-semibold text-white">Khóa quyền truy cập người dùng</h2>
            <p className="text-xs text-slate-400">Tài khoản này sẽ bị chặn gọi API ngay lập tức</p>
          </div>
        </div>

        <div className="my-4">
          <label className="block text-xs font-medium text-slate-300 mb-1.5 uppercase tracking-wider">
            Lý do khóa tài khoản <span className="text-rose-400">*</span>
          </label>
          <textarea
            id="ban-reason-input"
            value={reason}
            onChange={(e) => setReason(e.target.value)}
            placeholder="Nhập lý do vi phạm hoặc hành vi spam (tối thiểu 10 ký tự)..."
            rows={3}
            className="w-full bg-slate-900 border border-slate-700/80 rounded-xl px-3.5 py-2.5 text-white text-sm outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-500 transition-all placeholder:text-slate-500 resize-none"
          />
          {reason.length > 0 && !isValid && (
            <p className="text-xs text-rose-400 mt-1.5">Lý do cần tối thiểu 10 ký tự.</p>
          )}
        </div>

        <div className="flex gap-3 mt-6">
          <button
            id="ban-cancel-btn"
            onClick={onCancel}
            disabled={isLoading}
            className="flex-1 py-2 rounded-xl border border-slate-700/80 text-slate-300 text-sm font-medium hover:bg-slate-800/60 transition-colors disabled:opacity-50"
          >
            Hủy thao tác
          </button>
          <button
            id="ban-confirm-btn"
            onClick={() => isValid && onConfirm(reason.trim())}
            disabled={!isValid || isLoading}
            className="flex-1 py-2 rounded-xl bg-rose-600 text-white text-sm font-medium hover:bg-rose-500 transition-colors disabled:opacity-40 disabled:cursor-not-allowed shadow-sm"
          >
            {isLoading ? "Đang xử lý..." : "Xác nhận khóa"}
          </button>
        </div>
      </div>
    </div>
  );
}
