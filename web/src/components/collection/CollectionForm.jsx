import { useState, useEffect } from "react";
import Modal from "../common/Modal";
import Input from "../common/Input";
import Button from "../common/Button";

export default function CollectionForm({
  isOpen,
  onClose,
  onSubmit,
  initialData = null,
  isSubmitting = false,
}) {
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");
  const [error, setError] = useState("");

  useEffect(() => {
    if (initialData) {
      setName(initialData.name || "");
      setDescription(initialData.description || "");
    } else {
      setName("");
      setDescription("");
    }
    setError("");
  }, [initialData, isOpen]);

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!name.trim()) {
      setError("Tên bộ sưu tập không được để trống");
      return;
    }

    onSubmit({
      name: name.trim(),
      description: description.trim() || null,
    });
  };

  return (
    <Modal
      isOpen={isOpen}
      onClose={onClose}
      title={initialData ? "Chỉnh sửa bộ sưu tập" : "Tạo bộ sưu tập mới"}
    >
      <form onSubmit={handleSubmit} className="flex flex-col gap-4">
        <Input
          id="collection-name"
          label="Tên bộ sưu tập"
          placeholder="Ví dụ: IELTS Vocabulary, Travel, Tech..."
          value={name}
          onChange={(e) => {
            setName(e.target.value);
            if (error) setError("");
          }}
          error={error}
          autoFocus
        />

        <div className="flex flex-col gap-1.5">
          <label className="text-body-sm text-graphite font-medium">
            Mô tả (tùy chọn)
          </label>
          <textarea
            rows={3}
            placeholder="Ghi chú ngắn về bộ sưu tập này..."
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            className="w-full px-3 py-2 rounded-lg border border-stone bg-eggshell text-body placeholder:text-ash focus:outline-none focus:border-ink resize-none"
          />
        </div>

        <div className="flex justify-end gap-3 mt-4 pt-4 border-t border-stone">
          <Button type="button" variant="secondary" onClick={onClose}>
            Hủy
          </Button>
          <Button type="submit" disabled={isSubmitting}>
            {isSubmitting
              ? "Đang lưu..."
              : initialData
                ? "Lưu thay đổi"
                : "Tạo bộ sưu tập"}
          </Button>
        </div>
      </form>
    </Modal>
  );
}
