import { useState, useEffect } from "react";
import { useParams, useNavigate, Link } from "react-router-dom";
import { collectionService } from "../services/collection.service";
import { useUIStore } from "../stores/ui.store";
import Header from "../components/layout/Header";
import Button from "../components/common/Button";
import LoadingSpinner from "../components/common/LoadingSpinner";
import ConfirmDialog from "../components/common/ConfirmDialog";

export default function CollectionDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const addToast = useUIStore((s) => s.addToast);

  const [collection, setCollection] = useState(null);
  const [vocabularies, setVocabularies] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [removingWordId, setRemovingWordId] = useState(null);

  const loadData = async () => {
    setIsLoading(true);
    try {
      const data = await collectionService.getById(id);
      if (!data) {
        addToast("Không tìm thấy bộ sưu tập", "error");
        navigate("/collections");
        return;
      }
      setCollection(data.collection);
      setVocabularies(data.vocabularies);
    } catch (err) {
      addToast(err.message || "Lỗi tải bộ sưu tập", "error");
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, [id]);

  const handleRemoveWord = async () => {
    if (!removingWordId) return;
    try {
      await collectionService.removeWord(removingWordId, id);
      setVocabularies((prev) => prev.filter((v) => v.id !== removingWordId));
      addToast("Đã bỏ từ ra khỏi bộ sưu tập", "success");
    } catch (err) {
      addToast(err.message || "Lỗi bỏ từ", "error");
    } finally {
      setRemovingWordId(null);
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  if (!collection) return null;

  return (
    <>
      <Header
        title={collection.name}
        actions={
          <div className="flex items-center gap-3">
            <Button
              variant="secondary"
              onClick={() => navigate("/collections")}
            >
              ← Quay lại
            </Button>
            <Link to="/vocabulary/add">
              <Button>+ Thêm từ mới</Button>
            </Link>
          </div>
        }
      />

      <div className="p-6 max-w-4xl mx-auto">
        {collection.description && (
          <p className="text-body text-smoke mb-6 card-taupe">
            {collection.description}
          </p>
        )}

        <div className="flex items-center justify-between mb-4">
          <h2 className="text-heading-sm font-display font-light">
            Từ vựng ({vocabularies.length})
          </h2>
        </div>

        {vocabularies.length === 0 ? (
          <div className="text-center py-12 card-taupe rounded-card">
            <p className="text-smoke text-body-sm">
              Chưa có từ vựng nào trong bộ sưu tập này.
            </p>
            <Link to="/vocabulary/add" className="inline-block mt-4">
              <Button size="sm">+ Thêm từ ngay</Button>
            </Link>
          </div>
        ) : (
          <div className="flex flex-col gap-3">
            {vocabularies.map((vocab) => (
              <div
                key={vocab.id}
                className="card-taupe flex items-center justify-between gap-4 hover:border-graphite/20 transition-all"
              >
                <div className="flex-1">
                  <div className="flex items-center gap-3">
                    <Link
                      to={`/vocabulary/${vocab.id}`}
                      className="text-body font-medium text-ink hover:underline"
                    >
                      {vocab.word}
                    </Link>
                    {vocab.part_of_speech && (
                      <span className="px-2 py-0.5 bg-eggshell text-smoke rounded-pill text-caption border border-stone font-medium">
                        {vocab.part_of_speech}
                      </span>
                    )}
                    {vocab.phonetic && (
                      <span className="text-caption text-ash font-mono">
                        {vocab.phonetic}
                      </span>
                    )}
                  </div>
                  {vocab.definitions?.[0]?.definition_vi && (
                    <p className="text-body-sm text-smoke mt-1">
                      {vocab.definitions[0].definition_vi}
                    </p>
                  )}
                </div>

                <button
                  onClick={() => setRemovingWordId(vocab.id)}
                  className="text-caption text-red-600 hover:text-red-800 font-medium px-2 py-1 rounded hover:bg-red-50 transition-colors"
                  title="Bỏ khỏi bộ sưu tập"
                >
                  Bỏ ra
                </button>
              </div>
            ))}
          </div>
        )}
      </div>

      <ConfirmDialog
        isOpen={!!removingWordId}
        title="Bỏ từ khỏi bộ sưu tập"
        message="Từ vựng vẫn sẽ được lưu trong sổ từ của bạn, chỉ bị gỡ khỏi bộ sưu tập này."
        confirmText="Bỏ ra"
        variant="danger"
        onConfirm={handleRemoveWord}
        onCancel={() => setRemovingWordId(null)}
      />
    </>
  );
}
