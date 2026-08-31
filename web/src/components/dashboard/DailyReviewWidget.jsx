import { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import Button from "../common/Button";
import { CEFR_COLORS } from "../../utils/constants";

export default function DailyReviewWidget({ randomWord, onNextWord, isLoading }) {
  const [mode, setMode] = useState("gentle"); // "gentle" | "quiz"
  const [isRevealed, setIsRevealed] = useState(false);

  useEffect(() => {
    setIsRevealed(false);
  }, [randomWord]);

  const handlePlayAudio = (e, url) => {
    e.stopPropagation();
    if (!url) return;
    const audio = new Audio(url);
    audio.play().catch((err) => console.error("Audio error:", err));
  };

  if (isLoading) {
    return (
      <div className="card-taupe p-8 rounded-card-lg animate-pulse flex flex-col items-center justify-center min-h-[220px]">
        <div className="h-6 w-32 bg-stone rounded-pill mb-4" />
        <div className="h-4 w-48 bg-stone rounded-pill" />
      </div>
    );
  }

  if (!randomWord) {
    return (
      <div className="card-taupe p-8 rounded-card-lg text-center">
        <h3 className="text-heading-sm font-display font-light text-ink">
          Ôn tập hàng ngày (Daily Review)
        </h3>
        <p className="text-body-sm text-smoke mt-2 max-w-md mx-auto">
          Chưa có từ vựng nào để ôn tập. Thêm từ mới vào sổ tay để kích hoạt Daily Review nhé!
        </p>
        <Link to="/vocabulary/add" className="inline-block mt-4">
          <Button size="sm">+ Thêm từ ngay</Button>
        </Link>
      </div>
    );
  }

  const cefrStyle = CEFR_COLORS[randomWord.cefr_level] || {};

  return (
    <div className="card-taupe p-6 sm:p-8 rounded-card-lg relative border border-stone/80">
      {/* Header controls */}
      <div className="flex items-center justify-between gap-4 mb-6">
        <div className="flex items-center gap-2">
          <span className="text-subheading font-display font-light text-ink">
            ✨ Ôn tập ngẫu nhiên
          </span>
        </div>

        <div className="flex items-center gap-3">
          {/* Mode Switcher */}
          <div className="flex bg-eggshell p-1 rounded-pill border border-stone text-caption font-medium">
            <button
              onClick={() => setMode("gentle")}
              className={`px-3 py-1 rounded-pill transition-all ${
                mode === "gentle"
                  ? "bg-ink text-eggshell"
                  : "text-smoke hover:text-ink"
              }`}
            >
              Xem nhanh
            </button>
            <button
              onClick={() => setMode("quiz")}
              className={`px-3 py-1 rounded-pill transition-all ${
                mode === "quiz"
                  ? "bg-ink text-eggshell"
                  : "text-smoke hover:text-ink"
              }`}
            >
              Quiz (Ẩn nghĩa)
            </button>
          </div>

          <Button variant="ghost" size="sm" onClick={onNextWord} title="Đổi từ khác">
            🎲 Đổi từ
          </Button>
        </div>
      </div>

      {/* Main Flashcard Content */}
      <div className="flex flex-col items-start gap-4">
        <div className="flex items-center gap-3">
          <Link
            to={`/vocabulary/${randomWord.id}`}
            className="text-display font-display font-light text-ink hover:underline"
          >
            {randomWord.word}
          </Link>
          {randomWord.audio_url && (
            <button
              onClick={(e) => handlePlayAudio(e, randomWord.audio_url)}
              className="w-9 h-9 rounded-full bg-eggshell border border-stone flex items-center justify-center hover:bg-stone/50 transition-colors"
              title="Phát âm"
            >
              🔊
            </button>
          )}
        </div>

        {randomWord.phonetic && (
          <p className="text-body font-mono text-smoke">
            {randomWord.phonetic}
          </p>
        )}

        <div className="flex flex-wrap items-center gap-2">
          {randomWord.part_of_speech && (
            <span className="px-2.5 py-0.5 bg-eggshell text-graphite rounded-pill text-caption border border-stone font-medium">
              {randomWord.part_of_speech}
            </span>
          )}
          {randomWord.cefr_level && (
            <span
              className={`px-2.5 py-0.5 rounded-pill text-caption font-medium ${cefrStyle.bg || "bg-stone"} ${cefrStyle.text || "text-graphite"}`}
            >
              {randomWord.cefr_level}
            </span>
          )}
          {randomWord.usage_register && (
            <span className="px-2.5 py-0.5 bg-eggshell text-smoke rounded-pill text-caption border border-stone">
              {randomWord.usage_register}
            </span>
          )}
        </div>

        {/* Meaning Display */}
        {mode === "gentle" || isRevealed ? (
          <div className="w-full mt-2 pt-4 border-t border-stone flex flex-col gap-2">
            {randomWord.definitions && randomWord.definitions.length > 0 ? (
              randomWord.definitions.map((def, idx) => (
                <div key={def.id || idx} className="text-body text-ink">
                  {def.definition_vi && (
                    <p className="font-medium">→ {def.definition_vi}</p>
                  )}
                  {def.definition_en && (
                    <p className="text-body-sm text-smoke mt-0.5">
                      {def.definition_en}
                    </p>
                  )}
                  {def.example && (
                    <p className="text-caption text-ash italic mt-1">
                      "{def.example}"
                    </p>
                  )}
                </div>
              ))
            ) : (
              <p className="text-smoke text-body-sm">Chưa có định nghĩa</p>
            )}
          </div>
        ) : (
          <div className="w-full mt-2 pt-4 border-t border-stone">
            <button
              onClick={() => setIsRevealed(true)}
              className="w-full py-4 rounded-card bg-eggshell border border-dashed border-stone hover:border-graphite/40 text-body-sm text-smoke hover:text-ink transition-all"
            >
              👁️ Nhấn vào đây để xem nghĩa của từ
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
