export default function LookupResult({ result, onPlayAudio }) {
  if (!result) return null;

  return (
    <div className="flex items-center gap-4 p-4 bg-warm-taupe rounded-card">
      <div className="flex-1">
        <div className="flex items-center gap-3">
          <h3 className="text-heading-sm font-display font-light">
            {result.word}
          </h3>
          {result.audio_url && (
            <button
              onClick={() => onPlayAudio(result.audio_url)}
              className="w-8 h-8 rounded-full bg-eggshell border border-stone flex items-center justify-center hover:bg-stone/50 transition-colors"
              title="Phát âm"
            >
              🔊
            </button>
          )}
        </div>
        {result.phonetic && (
          <p className="text-body text-smoke font-mono mt-1">
            {result.phonetic}
          </p>
        )}
      </div>
      <div className="flex gap-2">
        {result.source?.dictionary && (
          <span className="px-2 py-0.5 bg-green-50 text-green-700 rounded-pill text-caption border border-green-200">
            Dictionary ✓
          </span>
        )}
        {result.source?.ai && (
          <span className="px-2 py-0.5 bg-blue-50 text-blue-700 rounded-pill text-caption border border-blue-200">
            AI ✓
          </span>
        )}
      </div>
    </div>
  );
}
