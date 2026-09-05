import { useState, useEffect } from "react";
import { useParams, useNavigate, Link } from "react-router-dom";
import { useAuthStore } from "../stores/auth.store";
import { collectionService } from "../services/collection.service";
import { vocabularyService } from "../services/vocabulary.service";
import { useUIStore } from "../stores/ui.store";
import Header from "../components/layout/Header";
import Button from "../components/common/Button";
import Input from "../components/common/Input";
import Modal from "../components/common/Modal";
import LoadingSpinner from "../components/common/LoadingSpinner";
import ConfirmDialog from "../components/common/ConfirmDialog";

export default function CollectionDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { user } = useAuthStore();
  const addToast = useUIStore((s) => s.addToast);

  const [collection, setCollection] = useState(null);
  const [vocabularies, setVocabularies] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [removingWordId, setRemovingWordId] = useState(null);

  // Modal for adding existing words
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);
  const [allUserVocabs, setAllUserVocabs] = useState([]);
  const [searchWord, setSearchWord] = useState("");
  const [isLoadingVocabs, setIsLoadingVocabs] = useState(false);

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

  const handleOpenAddExisting = async () => {
    setIsAddModalOpen(true);
    setSearchWord("");
    if (!user) return;
    setIsLoadingVocabs(true);
    try {
      const res = await vocabularyService.getAll(user.id, { limit: 100 });
      setAllUserVocabs(res.items || []);
    } catch (err) {
      addToast("Lỗi tải danh sách từ vựng", "error");
    } finally {
      setIsLoadingVocabs(false);
    }
  };

  const handleAddExistingWord = async (vocabId) => {
    try {
      await collectionService.assignWord(vocabId, id);
      addToast("Đã thêm từ vào bộ sưu tập!", "success");
      await loadData();
    } catch (err) {
      addToast(err.message || "Lỗi thêm từ", "error");
    }
  };

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
            <Button
              variant="secondary"
              onClick={handleOpenAddExisting}
            >
              + Chọn từ có sẵn
            </Button>
            <Link to={`/vocabulary/add?collectionId=${id}`}>
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
          <Button
            variant="secondary"
            size="sm"
            onClick={handleOpenAddExisting}
          >
            + Chọn từ có sẵn
          </Button>
        </div>

        {vocabularies.length === 0 ? (
          <div className="text-center py-12 card-taupe rounded-card flex flex-col items-center gap-3">
            <p className="text-smoke text-body-sm">
              Chưa có từ vựng nào trong bộ sưu tập này.
            </p>
            <div className="flex items-center gap-3 mt-2">
              <Button
                size="sm"
                variant="secondary"
                onClick={handleOpenAddExisting}
              >
                + Chọn từ có sẵn
              </Button>
              <Link to={`/vocabulary/add?collectionId=${id}`}>
                <Button size="sm">+ Thêm từ mới</Button>
              </Link>
            </div>
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
                  className="text-caption text-red-600 hover:text-red-800 dark:text-red-400 dark:hover:text-red-300 font-medium px-2 py-1 rounded hover:bg-red-50 dark:hover:bg-red-950/50 transition-colors"
                  title="Bỏ khỏi bộ sưu tập"
                >
                  Bỏ ra
                </button>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Modal: Add existing vocabulary */}
      <Modal
        isOpen={isAddModalOpen}
        onClose={() => setIsAddModalOpen(false)}
        title="Thêm từ vựng vào bộ sưu tập"
      >
        <div className="flex flex-col gap-4 max-h-[70vh]">
          <Input
            id="search-vocab-modal"
            placeholder="Tìm từ vựng trong kho của bạn..."
            value={searchWord}
            onChange={(e) => setSearchWord(e.target.value)}
            autoFocus
          />

          {isLoadingVocabs ? (
            <div className="py-8 flex justify-center">
              <LoadingSpinner size="md" />
            </div>
          ) : (
            <div className="overflow-y-auto flex flex-col gap-2 max-h-80 pr-1">
              {(() => {
                const filtered = allUserVocabs.filter(
                  (v) =>
                    !searchWord.trim() ||
                    v.word.toLowerCase().includes(searchWord.toLowerCase()) ||
                    v.definitions?.some(
                      (d) =>
                        d.definition_vi
                          ?.toLowerCase()
                          .includes(searchWord.toLowerCase()) ||
                        d.definition_en
                          ?.toLowerCase()
                          .includes(searchWord.toLowerCase()),
                    ),
                );

                if (filtered.length === 0) {
                  return (
                    <p className="text-body-sm text-smoke text-center py-6">
                      {searchWord
                        ? "Không tìm thấy từ vựng phù hợp."
                        : "Kho từ vựng của bạn chưa có từ nào."}
                    </p>
                  );
                }

                return filtered.map((v) => {
                  const isAlreadyIn = vocabularies.some(
                    (item) => item.id === v.id,
                  );
                  return (
                    <div
                      key={v.id}
                      className="flex items-center justify-between p-3 rounded-lg border border-stone bg-warm-taupe/40"
                    >
                      <div className="min-w-0 flex-1 mr-3">
                        <div className="flex items-center gap-2">
                          <span className="text-body font-medium text-ink">
                            {v.word}
                          </span>
                          {v.part_of_speech && (
                            <span className="text-caption text-smoke px-1.5 py-0.5 rounded bg-eggshell border border-stone">
                              {v.part_of_speech}
                            </span>
                          )}
                        </div>
                        {v.definitions?.[0]?.definition_vi && (
                          <p className="text-caption text-smoke mt-0.5 truncate">
                            {v.definitions[0].definition_vi}
                          </p>
                        )}
                      </div>

                      {isAlreadyIn ? (
                        <span className="text-caption text-emerald-700 dark:text-emerald-300 font-medium px-2 py-1 bg-emerald-50 dark:bg-emerald-950/70 rounded border border-emerald-200 dark:border-emerald-800">
                          ✓ Đã thêm
                        </span>
                      ) : (
                        <Button
                          size="sm"
                          variant="secondary"
                          onClick={() => handleAddExistingWord(v.id)}
                        >
                          + Thêm
                        </Button>
                      )}
                    </div>
                  );
                });
              })()}
            </div>
          )}

          <div className="flex justify-between items-center pt-3 border-t border-stone">
            <Link
              to={`/vocabulary/add?collectionId=${id}`}
              onClick={() => setIsAddModalOpen(false)}
              className="text-body-sm text-ink underline font-medium hover:text-smoke"
            >
              + Hoặc tạo từ mới hoàn toàn
            </Link>
            <Button
              variant="secondary"
              onClick={() => setIsAddModalOpen(false)}
            >
              Đóng
            </Button>
          </div>
        </div>
      </Modal>

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
