import { useState } from "react";
import Button from "../common/Button";
import Input from "../common/Input";
import {
  CEFR_LEVELS,
  PARTS_OF_SPEECH,
  USAGE_REGISTERS,
} from "../../utils/constants";

export default function WordForm({
  initialData,
  collections = [],
  assignedCollectionIds = [],
  onSubmit,
  onCancel,
  isSubmitting = false,
  submitLabel = "Lưu thay đổi",
}) {
  const [formData, setFormData] = useState({
    word: initialData?.vocabulary?.word || "",
    phonetic: initialData?.vocabulary?.phonetic || "",
    part_of_speech: initialData?.vocabulary?.part_of_speech || "",
    cefr_level: initialData?.vocabulary?.cefr_level || "",
    usage_register: initialData?.vocabulary?.usage_register || "",
  });

  const [definitions, setDefinitions] = useState(
    initialData?.definitions && initialData.definitions.length > 0
      ? initialData.definitions.map((d) => ({ ...d }))
      : [{ definition_en: "", definition_vi: "", example: "" }],
  );

  const [selectedColIds, setSelectedColIds] = useState(assignedCollectionIds);
  const [error, setError] = useState("");

  const handleDefChange = (index, field, value) => {
    setDefinitions((prev) =>
      prev.map((d, i) => (i === index ? { ...d, [field]: value } : d)),
    );
  };

  const handleAddDefinition = () => {
    setDefinitions((prev) => [
      ...prev,
      { definition_en: "", definition_vi: "", example: "" },
    ]);
  };

  const handleRemoveDefinition = (index) => {
    if (definitions.length <= 1) return;
    setDefinitions((prev) => prev.filter((_, i) => i !== index));
  };

  const handleToggleCollection = (colId) => {
    setSelectedColIds((prev) =>
      prev.includes(colId)
        ? prev.filter((id) => id !== colId)
        : [...prev, colId],
    );
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!formData.word.trim()) {
      setError("Từ vựng không được để trống");
      return;
    }

    const validDefs = definitions.filter(
      (d) => d.definition_en?.trim() || d.definition_vi?.trim(),
    );

    if (validDefs.length === 0) {
      setError("Cần có ít nhất một định nghĩa tiếng Anh hoặc tiếng Việt");
      return;
    }

    onSubmit({
      vocabulary: {
        ...formData,
        word: formData.word.trim(),
        phonetic: formData.phonetic.trim() || null,
        part_of_speech: formData.part_of_speech || null,
        cefr_level: formData.cefr_level || null,
        usage_register: formData.usage_register || null,
      },
      definitions: validDefs,
      collectionIds: selectedColIds,
    });
  };

  return (
    <form onSubmit={handleSubmit} className="flex flex-col gap-6">
      {error && (
        <div className="p-3 bg-red-50 border border-red-200 rounded-lg text-body-sm text-red-700">
          {error}
        </div>
      )}

      {/* Vocabulary basic details */}
      <div className="card-taupe flex flex-col gap-4">
        <h3 className="text-subheading font-display font-light text-ink">
          Thông tin từ
        </h3>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <Input
            id="word"
            label="Từ (Word)"
            value={formData.word}
            onChange={(e) => {
              setFormData({ ...formData, word: e.target.value });
              if (error) setError("");
            }}
          />

          <Input
            id="phonetic"
            label="Phiên âm (IPA)"
            placeholder="/fəˈnet.ɪk/"
            value={formData.phonetic}
            onChange={(e) =>
              setFormData({ ...formData, phonetic: e.target.value })
            }
          />
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div className="flex flex-col gap-1.5">
            <label className="text-body-sm text-graphite font-medium">
              Loại từ (Part of Speech)
            </label>
            <select
              value={formData.part_of_speech}
              onChange={(e) =>
                setFormData({ ...formData, part_of_speech: e.target.value })
              }
              className="w-full px-3 py-2 rounded-lg border border-stone bg-eggshell text-body text-graphite focus:outline-none focus:border-ink"
            >
              <option value="">— Chọn —</option>
              {PARTS_OF_SPEECH.map((pos) => (
                <option key={pos} value={pos}>
                  {pos}
                </option>
              ))}
            </select>
          </div>

          <div className="flex flex-col gap-1.5">
            <label className="text-body-sm text-graphite font-medium">
              CEFR Level
            </label>
            <select
              value={formData.cefr_level}
              onChange={(e) =>
                setFormData({ ...formData, cefr_level: e.target.value })
              }
              className="w-full px-3 py-2 rounded-lg border border-stone bg-eggshell text-body text-graphite focus:outline-none focus:border-ink"
            >
              <option value="">— Chọn —</option>
              {CEFR_LEVELS.map((lvl) => (
                <option key={lvl} value={lvl}>
                  {lvl}
                </option>
              ))}
            </select>
          </div>

          <div className="flex flex-col gap-1.5">
            <label className="text-body-sm text-graphite font-medium">
              Ngữ cảnh (Usage)
            </label>
            <select
              value={formData.usage_register}
              onChange={(e) =>
                setFormData({ ...formData, usage_register: e.target.value })
              }
              className="w-full px-3 py-2 rounded-lg border border-stone bg-eggshell text-body text-graphite focus:outline-none focus:border-ink"
            >
              <option value="">— Chọn —</option>
              {USAGE_REGISTERS.map((u) => (
                <option key={u} value={u}>
                  {u}
                </option>
              ))}
            </select>
          </div>
        </div>
      </div>

      {/* Definitions list */}
      <div className="card-taupe flex flex-col gap-4">
        <div className="flex items-center justify-between">
          <h3 className="text-subheading font-display font-light text-ink">
            Định nghĩa & Ví dụ
          </h3>
          <Button
            type="button"
            variant="ghost"
            size="sm"
            onClick={handleAddDefinition}
          >
            + Thêm định nghĩa
          </Button>
        </div>

        <div className="flex flex-col gap-4">
          {definitions.map((def, idx) => (
            <div
              key={idx}
              className="p-4 bg-eggshell border border-stone rounded-lg flex flex-col gap-3 relative"
            >
              <div className="flex items-center justify-between">
                <span className="text-caption text-smoke font-medium">
                  Định nghĩa #{idx + 1}
                </span>
                {definitions.length > 1 && (
                  <button
                    type="button"
                    onClick={() => handleRemoveDefinition(idx)}
                    className="text-caption text-red-600 hover:text-red-800"
                  >
                    Xóa
                  </button>
                )}
              </div>

              <Input
                id={`def-vi-${idx}`}
                label="Nghĩa tiếng Việt"
                placeholder="Ví dụ: kiên cường, hồi phục nhanh"
                value={def.definition_vi || ""}
                onChange={(e) =>
                  handleDefChange(idx, "definition_vi", e.target.value)
                }
              />

              <Input
                id={`def-en-${idx}`}
                label="Định nghĩa tiếng Anh (tùy chọn)"
                placeholder="English definition..."
                value={def.definition_en || ""}
                onChange={(e) =>
                  handleDefChange(idx, "definition_en", e.target.value)
                }
              />

              <div className="flex flex-col gap-1.5">
                <label className="text-body-sm text-graphite font-medium">
                  Câu ví dụ (tùy chọn)
                </label>
                <input
                  type="text"
                  placeholder="Ví dụ: She remained resilient in face of adversity."
                  value={def.example || ""}
                  onChange={(e) =>
                    handleDefChange(idx, "example", e.target.value)
                  }
                  className="w-full px-3 py-2 rounded-lg border border-stone bg-eggshell text-body text-graphite placeholder:text-ash focus:outline-none focus:border-ink"
                />
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Collection assignment */}
      {collections.length > 0 && (
        <div className="card-taupe flex flex-col gap-3">
          <h3 className="text-subheading font-display font-light text-ink">
            Bộ sưu tập
          </h3>
          <div className="flex flex-wrap gap-2">
            {collections.map((col) => {
              const isSelected = selectedColIds.includes(col.id);
              return (
                <button
                  key={col.id}
                  type="button"
                  onClick={() => handleToggleCollection(col.id)}
                  className={`px-3 py-1.5 rounded-pill text-body-sm transition-all ${
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

      {/* Buttons */}
      <div className="flex items-center justify-end gap-3 pt-4 border-t border-stone">
        <Button type="button" variant="secondary" onClick={onCancel}>
          Hủy
        </Button>
        <Button type="submit" disabled={isSubmitting}>
          {isSubmitting ? "Đang lưu..." : submitLabel}
        </Button>
      </div>
    </form>
  );
}
