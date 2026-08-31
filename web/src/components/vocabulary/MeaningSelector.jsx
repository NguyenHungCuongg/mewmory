import { useState } from "react";

export default function MeaningSelector({
  meanings,
  selectedMeanings,
  onSelectionChange,
}) {
  const handleToggleMeaning = (meaningIdx, defIdx) => {
    const key = `${meaningIdx}-${defIdx}`;
    const newSelection = { ...selectedMeanings };
    if (newSelection[key]) {
      delete newSelection[key];
    } else {
      newSelection[key] = { meaningIdx, defIdx };
    }
    onSelectionChange(newSelection);
  };

  if (!meanings || meanings.length === 0) {
    return <p className="text-smoke text-body-sm">Không tìm thấy nghĩa nào.</p>;
  }

  return (
    <div className="flex flex-col gap-4">
      {meanings.map((meaning, mIdx) => (
        <div key={mIdx} className="card-taupe">
          <div className="flex items-center gap-2 mb-3">
            <span className="px-2 py-0.5 bg-eggshell rounded-pill text-body-sm text-ink font-medium border border-stone">
              {meaning.part_of_speech}
            </span>
            {meaning.cefr_level && (
              <span className="px-2 py-0.5 bg-eggshell rounded-pill text-body-sm text-smoke border border-stone">
                {meaning.cefr_level}
              </span>
            )}
            {meaning.usage_register && (
              <span className="px-2 py-0.5 bg-eggshell rounded-pill text-body-sm text-smoke border border-stone">
                {meaning.usage_register}
              </span>
            )}
          </div>

          <div className="flex flex-col gap-2">
            {meaning.definitions.map((def, dIdx) => {
              const key = `${mIdx}-${dIdx}`;
              const isSelected = !!selectedMeanings[key];

              return (
                <label
                  key={dIdx}
                  className={`flex items-start gap-3 p-3 rounded-lg cursor-pointer transition-colors ${
                    isSelected
                      ? "bg-eggshell border border-ink/10"
                      : "hover:bg-eggshell/60"
                  }`}
                >
                  <input
                    type="checkbox"
                    checked={isSelected}
                    onChange={() => handleToggleMeaning(mIdx, dIdx)}
                    className="mt-1 accent-ink"
                  />
                  <div className="flex-1">
                    {def.definition_en && (
                      <p className="text-body-sm text-ink">
                        {def.definition_en}
                      </p>
                    )}
                    {def.definition_vi && (
                      <p className="text-body-sm text-smoke mt-0.5">
                        → {def.definition_vi}
                      </p>
                    )}
                    {def.example && (
                      <p className="text-caption text-ash mt-1 italic">
                        "{def.example}"
                      </p>
                    )}
                  </div>
                </label>
              );
            })}
          </div>
        </div>
      ))}
    </div>
  );
}
