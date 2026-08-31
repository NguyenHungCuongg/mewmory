import { Link } from "react-router-dom";

export default function CollectionCard({ collection, onEdit, onDelete }) {
  return (
    <div className="card-taupe flex flex-col justify-between hover:border-graphite/20 transition-all">
      <div>
        <div className="flex items-start justify-between gap-2">
          <Link
            to={`/collections/${collection.id}`}
            className="text-heading-sm font-display font-light text-ink hover:underline"
          >
            {collection.name}
          </Link>
          <div className="flex items-center gap-1.5">
            {collection.is_default && (
              <span className="px-2 py-0.5 bg-stone text-graphite rounded-pill text-caption font-medium">
                Default
              </span>
            )}
            {collection.is_ai_generated && (
              <span className="px-2 py-0.5 bg-blue-50 text-blue-700 border border-blue-200 rounded-pill text-caption font-medium">
                AI
              </span>
            )}
          </div>
        </div>

        {collection.description && (
          <p className="text-body-sm text-smoke mt-2 line-clamp-2">
            {collection.description}
          </p>
        )}
      </div>

      <div className="flex items-center justify-between mt-6 pt-4 border-t border-stone">
        <span className="text-caption text-ash font-medium">
          {collection.word_count || 0}{" "}
          {(collection.word_count || 0) === 1 ? "word" : "words"}
        </span>

        <div className="flex items-center gap-2">
          {onEdit && (
            <button
              onClick={() => onEdit(collection)}
              className="text-caption text-graphite hover:text-ink font-medium px-2 py-1 rounded hover:bg-stone/50 transition-colors"
            >
              Sửa
            </button>
          )}
          {onDelete && !collection.is_default && (
            <button
              onClick={() => onDelete(collection)}
              className="text-caption text-red-600 hover:text-red-800 font-medium px-2 py-1 rounded hover:bg-red-50 transition-colors"
            >
              Xóa
            </button>
          )}
        </div>
      </div>
    </div>
  );
}
