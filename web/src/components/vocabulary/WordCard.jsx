import { Link } from "react-router-dom";
import { CEFR_COLORS } from "../../utils/constants";
import { truncateText } from "../../utils/formatters";

export default function WordCard({ vocabulary }) {
  const cefrStyle = CEFR_COLORS[vocabulary.cefr_level] || {};

  return (
    <Link
      to={`/vocabulary/${vocabulary.id}`}
      className="card-taupe block hover:border-graphite/20 transition-all duration-200"
    >
      <div className="flex items-start justify-between mb-2">
        <h3 className="text-subheading font-display font-light text-ink">
          {vocabulary.word}
        </h3>
        <div className="flex gap-1.5">
          {vocabulary.part_of_speech && (
            <span className="px-2 py-0.5 bg-eggshell border border-stone rounded-pill text-caption text-smoke font-medium">
              {vocabulary.part_of_speech}
            </span>
          )}
          {vocabulary.cefr_level && (
            <span
              className={`px-2 py-0.5 rounded-pill text-caption font-medium ${cefrStyle.bg || "bg-stone"} ${cefrStyle.text || "text-graphite"}`}
            >
              {vocabulary.cefr_level}
            </span>
          )}
        </div>
      </div>

      {vocabulary.phonetic && (
        <p className="text-body-sm text-smoke font-mono mb-2">
          {vocabulary.phonetic}
        </p>
      )}

      {vocabulary.definitions && vocabulary.definitions.length > 0 && (
        <p className="text-body-sm text-graphite">
          {truncateText(
            vocabulary.definitions[0].definition_vi ||
              vocabulary.definitions[0].definition_en ||
              "",
            80,
          )}
        </p>
      )}
    </Link>
  );
}
