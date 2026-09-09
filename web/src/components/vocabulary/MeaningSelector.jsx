import { useState } from "react";
import { lookupService } from "../../services/lookup.service";

export default function MeaningSelector({
  meanings = [],
  selectedMeanings = {},
  word = "",
  onSelectionChange,
  onMeaningsChange,
  onTranslateDefinition,
  provider,
  model,
}) {
  const [translatingKeys, setTranslatingKeys] = useState({});
  const [translateErrors, setTranslateErrors] = useState({});

  const handleToggleMeaning = (meaningIdx, defIdx) => {
    const key = `${meaningIdx}-${defIdx}`;
    const newSelection = { ...selectedMeanings };
    if (newSelection[key]) {
      delete newSelection[key];
    } else {
      newSelection[key] = { meaningIdx, defIdx };
    }
    onSelectionChange?.(newSelection);
  };

  const handleUpdateDef = (mIdx, dIdx, field, value) => {
    const updatedMeanings = meanings.map((m, currentMIdx) => {
      if (currentMIdx !== mIdx) return m;
      const updatedDefs = m.definitions.map((d, currentDIdx) => {
        if (currentDIdx !== dIdx) return d;
        return { ...d, [field]: value };
      });
      return { ...m, definitions: updatedDefs };
    });
    onMeaningsChange?.(updatedMeanings);
  };

  const handleTranslate = async (mIdx, dIdx) => {
    const meaning = meanings[mIdx];
    const def = meaning?.definitions?.[dIdx];
    if (!def) return;

    const textToTranslate = def.definition_en || word;
    if (!textToTranslate) return;

    const key = `${mIdx}-${dIdx}`;
    setTranslatingKeys((prev) => ({ ...prev, [key]: true }));
    setTranslateErrors((prev) => ({ ...prev, [key]: null }));

    try {
      let translation = "";
      const payload = {
        text: textToTranslate,
        partOfSpeech: meaning.part_of_speech || "",
        word,
      };
      if (provider) payload.provider = provider;
      if (model) payload.model = model;

      if (onTranslateDefinition) {
        translation = await onTranslateDefinition(payload);
      } else {
        translation = await lookupService.translateDefinition(payload);
      }

      if (translation) {
        handleUpdateDef(mIdx, dIdx, "definition_vi", translation);
      }
    } catch (err) {
      console.error("Translation error:", err);
      setTranslateErrors((prev) => ({
        ...prev,
        [key]: "Dịch thất bại, vui lòng thử lại",
      }));
    } finally {
      setTranslatingKeys((prev) => ({ ...prev, [key]: false }));
    }
  };

  const handleAddDef = (mIdx) => {
    const newDef = {
      definition_en: "",
      definition_vi: "",
      example: "",
      isCustom: true,
    };
    const currentDefsCount = meanings[mIdx]?.definitions?.length || 0;
    const updatedMeanings = meanings.map((m, currentMIdx) => {
      if (currentMIdx !== mIdx) return m;
      return { ...m, definitions: [...(m.definitions || []), newDef] };
    });

    const newKey = `${mIdx}-${currentDefsCount}`;
    const newSelection = {
      ...selectedMeanings,
      [newKey]: { meaningIdx: mIdx, defIdx: currentDefsCount },
    };

    onMeaningsChange?.(updatedMeanings);
    onSelectionChange?.(newSelection);
  };

  const handleDeleteDef = (mIdx, dIdx) => {
    const updatedMeanings = meanings.map((m, currentMIdx) => {
      if (currentMIdx !== mIdx) return m;
      const updatedDefs = (m.definitions || []).filter(
        (_, currentDIdx) => currentDIdx !== dIdx,
      );
      return { ...m, definitions: updatedDefs };
    });

    // Shift keys in selectedMeanings
    const newSelection = {};
    for (const [key, val] of Object.entries(selectedMeanings)) {
      const [smIdx, sdIdx] = key.split("-").map(Number);
      if (smIdx !== mIdx) {
        newSelection[key] = val;
      } else if (sdIdx < dIdx) {
        newSelection[key] = val;
      } else if (sdIdx > dIdx) {
        const newKey = `${smIdx}-${sdIdx - 1}`;
        newSelection[newKey] = { meaningIdx: smIdx, defIdx: sdIdx - 1 };
      }
    }

    onMeaningsChange?.(updatedMeanings);
    onSelectionChange?.(newSelection);
  };

  const totalDefsCount = meanings.reduce(
    (acc, m) => acc + (m.definitions?.length || 0),
    0,
  );
  const selectedCount = Object.keys(selectedMeanings).length;
  const isAllSelected = totalDefsCount > 0 && selectedCount >= totalDefsCount;

  const handleToggleSelectAll = () => {
    if (isAllSelected) {
      onSelectionChange?.({});
    } else {
      const allSelected = {};
      meanings.forEach((m, mIdx) => {
        (m.definitions || []).forEach((_, dIdx) => {
          allSelected[`${mIdx}-${dIdx}`] = { meaningIdx: mIdx, defIdx: dIdx };
        });
      });
      onSelectionChange?.(allSelected);
    }
  };

  if (!meanings || meanings.length === 0) {
    return <p className="text-smoke text-body-sm">Không tìm thấy nghĩa nào.</p>;
  }

  return (
    <div className="flex flex-col gap-4">
      {/* Bulk action toolbar */}
      <div className="flex items-center justify-between px-1">
        <span className="text-caption text-smoke">
          Đã chọn:{" "}
          <strong className="text-ink font-semibold">{selectedCount}</strong> /{" "}
          {totalDefsCount} định nghĩa
        </span>
        <button
          type="button"
          onClick={handleToggleSelectAll}
          className="text-caption text-ink font-medium hover:underline px-3 py-1 rounded-pill border border-stone hover:border-graphite/40 transition-colors bg-eggshell shadow-xs cursor-pointer"
        >
          {isAllSelected ? "Bỏ chọn tất cả" : "Chọn tất cả"}
        </button>
      </div>

      {meanings.map((meaning, mIdx) => (
        <div key={mIdx} className="card-taupe">
          <div className="flex items-center justify-between mb-3 gap-2">
            <div className="flex items-center gap-2 flex-wrap">
              <span className="px-2.5 py-0.5 bg-eggshell rounded-pill text-body-sm text-ink font-medium border border-stone">
                {meaning.part_of_speech || "other"}
              </span>
              {meaning.cefr_level && (
                <span className="px-2 py-0.5 bg-eggshell rounded-pill text-caption text-smoke border border-stone">
                  {meaning.cefr_level}
                </span>
              )}
              {meaning.usage_register && (
                <span className="px-2 py-0.5 bg-eggshell rounded-pill text-caption text-smoke border border-stone">
                  {meaning.usage_register}
                </span>
              )}
            </div>
            <button
              type="button"
              onClick={() => handleAddDef(mIdx)}
              className="text-caption text-ink font-medium px-2.5 py-1 rounded-pill border border-stone bg-eggshell hover:bg-warm-taupe transition-colors flex items-center gap-1 cursor-pointer shrink-0"
            >
              <span>+ Thêm nghĩa</span>
            </button>
          </div>

          <div className="flex flex-col gap-2.5">
            {(!meaning.definitions || meaning.definitions.length === 0) && (
              <p className="text-caption text-ash italic py-2 text-center">
                Chưa có định nghĩa nào cho từ loại này. Bấm "+ Thêm nghĩa" để tạo mới.
              </p>
            )}

            {meaning.definitions?.map((def, dIdx) => {
              const key = `${mIdx}-${dIdx}`;
              const isSelected = !!selectedMeanings[key];
              const isTranslating = !!translatingKeys[key];

              return (
                <div
                  key={dIdx}
                  className={`flex items-start gap-3 p-3 rounded-card transition-all border ${
                    isSelected
                      ? "bg-eggshell border-stone shadow-xs"
                      : "bg-warm-taupe/40 border-transparent hover:border-stone/60"
                  }`}
                >
                  <input
                    type="checkbox"
                    id={`def-check-${mIdx}-${dIdx}`}
                    checked={isSelected}
                    onChange={() => handleToggleMeaning(mIdx, dIdx)}
                    className="mt-1 accent-ink w-4 h-4 cursor-pointer shrink-0"
                    aria-label={`Chọn định nghĩa ${dIdx + 1}`}
                  />
                  <div className="flex-1 flex flex-col gap-1.5 min-w-0">
                    <div className="flex items-start justify-between gap-2">
                      {def.isCustom ? (
                        <input
                          type="text"
                          value={def.definition_en || ""}
                          placeholder="Định nghĩa tiếng Anh (tùy chọn)..."
                          onChange={(e) =>
                            handleUpdateDef(
                              mIdx,
                              dIdx,
                              "definition_en",
                              e.target.value,
                            )
                          }
                          className="flex-1 text-body-sm px-2 py-1 rounded bg-warm-taupe/50 dark:bg-stone/30 border border-stone focus:border-ink outline-none text-ink placeholder:text-ash"
                        />
                      ) : (
                        <p className="text-body-sm text-ink font-medium leading-snug">
                          {def.definition_en || "(Không có định nghĩa tiếng Anh)"}
                        </p>
                      )}
                      <button
                        type="button"
                        onClick={() => handleDeleteDef(mIdx, dIdx)}
                        title="Xóa định nghĩa này"
                        aria-label="Xóa định nghĩa"
                        className="text-ash hover:text-red-500 p-0.5 rounded transition-colors text-body-sm cursor-pointer shrink-0"
                      >
                        ✕
                      </button>
                    </div>

                    {/* Vietnamese translation input + translate button */}
                    <div className="flex items-center gap-2">
                      <span className="text-caption font-semibold text-smoke shrink-0">
                        VN:
                      </span>
                      <input
                        type="text"
                        value={def.definition_vi || ""}
                        placeholder="Nhập nghĩa tiếng Việt..."
                        onChange={(e) =>
                          handleUpdateDef(
                            mIdx,
                            dIdx,
                            "definition_vi",
                            e.target.value,
                          )
                        }
                        className={`flex-1 text-body-sm px-2.5 py-1 rounded border outline-none text-ink transition-colors ${
                          def.definition_vi
                            ? "bg-warm-taupe/40 dark:bg-stone/30 border-stone/80 focus:border-ink focus:bg-eggshell"
                            : "bg-amber-500/10 border-amber-500/30 focus:border-amber-500 placeholder:text-amber-700/60 dark:placeholder:text-amber-300/60"
                        }`}
                      />
                      <button
                        type="button"
                        onClick={() => handleTranslate(mIdx, dIdx)}
                        disabled={isTranslating}
                        title={
                          def.definition_vi
                            ? "Dịch lại nghĩa này bằng AI"
                            : "Dịch định nghĩa tiếng Anh sang tiếng Việt bằng AI"
                        }
                        className={`text-caption px-2.5 py-1 rounded border transition-colors flex items-center gap-1 shrink-0 cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed ${
                          def.definition_vi
                            ? "bg-transparent border-stone/60 text-smoke hover:text-ink hover:border-stone hover:bg-warm-taupe/30"
                            : "bg-ink text-eggshell border-ink hover:opacity-90 font-medium shadow-xs"
                        }`}
                      >
                        {isTranslating ? (
                          <>
                            <span className="inline-block w-3 h-3 border-2 border-current border-t-transparent rounded-full animate-spin" />
                            <span>Đang dịch...</span>
                          </>
                        ) : (
                          <>
                            <span>🔄</span>
                            <span>{def.definition_vi ? "Dịch lại" : "Dịch"}</span>
                          </>
                        )}
                      </button>
                    </div>
                    {translateErrors[key] && (
                      <p className="text-caption text-red-500 ml-7">
                        {translateErrors[key]}
                      </p>
                    )}

                    {/* Example input */}
                    <div className="flex items-center gap-2">
                      <span className="text-caption font-semibold text-ash shrink-0">
                        Ex:
                      </span>
                      <input
                        type="text"
                        value={def.example || ""}
                        placeholder="Câu ví dụ..."
                        onChange={(e) =>
                          handleUpdateDef(
                            mIdx,
                            dIdx,
                            "example",
                            e.target.value,
                          )
                        }
                        className="flex-1 text-caption italic px-2.5 py-0.5 rounded bg-transparent border-b border-stone focus:border-ink outline-none text-smoke placeholder:text-ash transition-colors"
                      />
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      ))}
    </div>
  );
}

