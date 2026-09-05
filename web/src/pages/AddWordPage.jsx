import { useState, useEffect, useCallback } from "react";
import { useNavigate, useSearchParams } from "react-router-dom";
import { useAuthStore } from "../stores/auth.store";
import { useCollectionStore } from "../stores/collection.store";
import { useUIStore } from "../stores/ui.store";
import { vocabularyService } from "../services/vocabulary.service";
import { lookupService } from "../services/lookup.service";
import { useOnlineStatus } from "../hooks/useOnlineStatus";
import { useDebouncedSearch } from "../hooks/useDebouncedSearch";
import { validateWord } from "../utils/validators";
import Header from "../components/layout/Header";
import Button from "../components/common/Button";
import Input from "../components/common/Input";
import LoadingSpinner from "../components/common/LoadingSpinner";
import LookupResult from "../components/vocabulary/LookupResult";
import MeaningSelector from "../components/vocabulary/MeaningSelector";
import DuplicateWarning from "../components/vocabulary/DuplicateWarning";

export default function AddWordPage() {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const defaultColId = searchParams.get("collectionId");
  const { user } = useAuthStore();
  const { items: collections, fetchCollections } = useCollectionStore();
  const addToast = useUIStore((s) => s.addToast);
  const { isOnline } = useOnlineStatus();

  const [word, setWord] = useState("");
  const [lookupResult, setLookupResult] = useState(null);
  const [selectedMeanings, setSelectedMeanings] = useState({});
  const [selectedColIds, setSelectedColIds] = useState(
    defaultColId ? [defaultColId] : [],
  );
  const [isLooking, setIsLooking] = useState(false);
  const [isSaving, setIsSaving] = useState(false);
  const [duplicateCount, setDuplicateCount] = useState(0);
  const [wordError, setWordError] = useState("");

  // Manual field overrides
  const [editFields, setEditFields] = useState({
    phonetic: "",
    cefr_level: "",
    usage_register: "",
  });

  const debouncedWord = useDebouncedSearch(word, 300);

  // Fetch collections
  useEffect(() => {
    if (user) {
      fetchCollections(user.id);
    }
  }, [user, fetchCollections]);

  // Check for duplicates on debounced word change
  useEffect(() => {
    if (debouncedWord && user) {
      vocabularyService
        .checkDuplicate(user.id, debouncedWord)
        .then(({ count }) => setDuplicateCount(count));
    } else {
      setDuplicateCount(0);
    }
  }, [debouncedWord, user]);

  const handleLookup = async () => {
    const validation = validateWord(word);
    if (!validation.valid) {
      setWordError(validation.error);
      return;
    }
    setWordError("");

    if (!isOnline) {
      addToast("Cần kết nối mạng để tra cứu", "error");
      return;
    }

    setIsLooking(true);
    try {
      const result = await lookupService.lookupWord(word);
      setLookupResult(result);
      setEditFields({
        phonetic: result.phonetic || "",
        cefr_level: result.meanings?.[0]?.cefr_level || "",
        usage_register: result.meanings?.[0]?.usage_register || "",
      });
      // Auto-select all meanings
      const selection = {};
      result.meanings?.forEach((m, mIdx) => {
        m.definitions?.forEach((_, dIdx) => {
          selection[`${mIdx}-${dIdx}`] = { meaningIdx: mIdx, defIdx: dIdx };
        });
      });
      setSelectedMeanings(selection);
    } catch (err) {
      addToast(err.message || "Lỗi tra cứu từ vựng", "error");
    } finally {
      setIsLooking(false);
    }
  };

  const handleSave = async () => {
    if (!user || Object.keys(selectedMeanings).length === 0) {
      addToast("Vui lòng chọn ít nhất 1 nghĩa", "error");
      return;
    }

    setIsSaving(true);
    try {
      // Group selected definitions by meaning (part_of_speech)
      const groupedByMeaning = {};
      for (const [key, { meaningIdx, defIdx }] of Object.entries(
        selectedMeanings,
      )) {
        if (!groupedByMeaning[meaningIdx]) groupedByMeaning[meaningIdx] = [];
        groupedByMeaning[meaningIdx].push(defIdx);
      }

      // Create one vocabulary entry per part_of_speech
      for (const [mIdxStr, defIndices] of Object.entries(groupedByMeaning)) {
        const mIdx = parseInt(mIdxStr);
        const meaning = lookupResult.meanings[mIdx];

        const vocabData = {
          user_id: user.id,
          word: lookupResult.word || word.trim(),
          phonetic: editFields.phonetic || lookupResult.phonetic || null,
          audio_url: lookupResult.audio_url || null,
          part_of_speech: meaning.part_of_speech || null,
          cefr_level: editFields.cefr_level || meaning.cefr_level || null,
          usage_register:
            editFields.usage_register || meaning.usage_register || null,
        };

        const definitions = defIndices.map((dIdx) => meaning.definitions[dIdx]);

        await vocabularyService.create(vocabData, definitions, selectedColIds);
      }

      addToast("Đã lưu thành công!", "success");
      navigate(defaultColId ? `/collections/${defaultColId}` : "/vocabulary");
    } catch (err) {
      addToast(err.message || "Lỗi lưu từ vựng", "error");
    } finally {
      setIsSaving(false);
    }
  };

  const handlePlayAudio = (url) => {
    const audio = new Audio(url);
    audio.play().catch(() => addToast("Không thể phát audio", "error"));
  };

  const handleKeyDown = (e) => {
    if (e.key === "Enter") handleLookup();
  };

  return (
    <>
      <Header title="Thêm từ mới" />
      <div className="p-6 max-w-2xl mx-auto">
        {/* Word input */}
        <div className="flex gap-3 mb-4">
          <Input
            id="word-input"
            placeholder="Nhập từ tiếng Anh..."
            value={word}
            onChange={(e) => setWord(e.target.value)}
            onKeyDown={handleKeyDown}
            error={wordError}
            className="flex-1"
          />
          <Button onClick={handleLookup} disabled={isLooking || !isOnline}>
            {isLooking ? <LoadingSpinner size="sm" /> : "Lookup"}
          </Button>
        </div>

        {/* Duplicate warning */}
        <DuplicateWarning count={duplicateCount} />

        {/* Offline notice */}
        {!isOnline && (
          <div className="mt-4 p-4 bg-amber-50 border border-amber-200 rounded-card text-body-sm text-amber-800">
            📡 Bạn đang offline. Bạn có thể tự điền tay tất cả các field.
          </div>
        )}

        {/* Loading */}
        {isLooking && (
          <div className="flex items-center justify-center py-12">
            <LoadingSpinner size="lg" />
          </div>
        )}

        {/* Results */}
        {lookupResult && !isLooking && (
          <div className="mt-6 flex flex-col gap-6">
            <LookupResult result={lookupResult} onPlayAudio={handlePlayAudio} />

            {/* Editable fields */}
            <div className="grid grid-cols-3 gap-4">
              <Input
                id="phonetic"
                label="Phiên âm (IPA)"
                value={editFields.phonetic}
                onChange={(e) =>
                  setEditFields({ ...editFields, phonetic: e.target.value })
                }
              />
              <div className="flex flex-col gap-1.5">
                <label className="text-body-sm text-graphite font-medium">
                  CEFR Level
                </label>
                <select
                  value={editFields.cefr_level}
                  onChange={(e) =>
                    setEditFields({ ...editFields, cefr_level: e.target.value })
                  }
                  className="w-full px-3 py-2 rounded border border-stone bg-eggshell text-body"
                >
                  <option value="">—</option>
                  {["A1", "A2", "B1", "B2", "C1", "C2"].map((l) => (
                    <option key={l} value={l}>
                      {l}
                    </option>
                  ))}
                </select>
              </div>
              <div className="flex flex-col gap-1.5">
                <label className="text-body-sm text-graphite font-medium">
                  Usage
                </label>
                <select
                  value={editFields.usage_register}
                  onChange={(e) =>
                    setEditFields({
                      ...editFields,
                      usage_register: e.target.value,
                    })
                  }
                  className="w-full px-3 py-2 rounded border border-stone bg-eggshell text-body"
                >
                  <option value="">—</option>
                  {[
                    "formal",
                    "informal",
                    "slang",
                    "neutral",
                    "vulgar",
                    "technical",
                  ].map((u) => (
                    <option key={u} value={u}>
                      {u}
                    </option>
                  ))}
                </select>
              </div>
            </div>

            {/* Meaning selection */}
            <div>
              <h3 className="text-subheading font-display font-light mb-3">
                Chọn nghĩa muốn lưu
              </h3>
              <MeaningSelector
                meanings={lookupResult.meanings}
                selectedMeanings={selectedMeanings}
                onSelectionChange={setSelectedMeanings}
              />
            </div>

            {/* Collection assignment */}
            {collections.length > 0 && (
              <div className="card-taupe flex flex-col gap-3">
                <h3 className="text-subheading font-display font-light text-ink">
                  Bộ sưu tập (tùy chọn)
                </h3>
                <p className="text-caption text-smoke">
                  Chọn một hoặc nhiều bộ sưu tập để gán từ này vào:
                </p>
                <div className="flex flex-wrap gap-2">
                  {collections.map((col) => {
                    const isSelected = selectedColIds.includes(col.id);
                    return (
                      <button
                        key={col.id}
                        type="button"
                        onClick={() =>
                          setSelectedColIds((prev) =>
                            isSelected
                              ? prev.filter((id) => id !== col.id)
                              : [...prev, col.id],
                          )
                        }
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

            {/* Save */}
            <div className="flex justify-end gap-3 pt-4 border-t border-stone">
              <Button
                variant="secondary"
                onClick={() => navigate("/vocabulary")}
              >
                Hủy
              </Button>
              <Button
                onClick={handleSave}
                disabled={
                  isSaving || Object.keys(selectedMeanings).length === 0
                }
              >
                {isSaving
                  ? "Đang lưu..."
                  : `Lưu (${Object.keys(selectedMeanings).length} nghĩa)`}
              </Button>
            </div>
          </div>
        )}
      </div>
    </>
  );
}
