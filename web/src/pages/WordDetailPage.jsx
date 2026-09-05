import { useState, useEffect } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { useAuthStore } from "../stores/auth.store";
import { useUIStore } from "../stores/ui.store";
import { vocabularyService } from "../services/vocabulary.service";
import { collectionService } from "../services/collection.service";
import Header from "../components/layout/Header";
import Button from "../components/common/Button";
import LoadingSpinner from "../components/common/LoadingSpinner";
import ConfirmDialog from "../components/common/ConfirmDialog";
import WordForm from "../components/vocabulary/WordForm";
import { CEFR_COLORS } from "../utils/constants";
import { formatDate } from "../utils/formatters";

export default function WordDetailPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { user } = useAuthStore();
  const addToast = useUIStore((s) => s.addToast);

  const [data, setData] = useState(null);
  const [allCollections, setAllCollections] = useState([]);
  const [isEditing, setIsEditing] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [isDeleting, setIsDeleting] = useState(false);
  const [isSaving, setIsSaving] = useState(false);

  const loadData = async () => {
    setIsLoading(true);
    try {
      const vocabData = await vocabularyService.getById(id);
      if (!vocabData) {
        addToast("Không tìm thấy từ vựng", "error");
        navigate("/vocabulary");
        return;
      }
      setData(vocabData);

      if (user) {
        const colData = await collectionService.getAll(user.id);
        setAllCollections(colData.items);
      }
    } catch (err) {
      addToast(err.message || "Lỗi tải từ vựng", "error");
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    loadData();
  }, [id, user]);

  const handlePlayAudio = (url) => {
    if (!url) return;
    const audio = new Audio(url);
    audio.play().catch(() => addToast("Không thể phát audio", "error"));
  };

  const handleUpdate = async (formData) => {
    setIsSaving(true);
    try {
      const updated = await vocabularyService.updateWithDetails(
        id,
        formData.vocabulary,
        formData.definitions,
        formData.collectionIds,
      );
      setData(updated);
      setIsEditing(false);
      addToast("Cập nhật từ vựng thành công!", "success");
    } catch (err) {
      addToast(err.message || "Lỗi cập nhật", "error");
    } finally {
      setIsSaving(false);
    }
  };

  const handleDelete = async () => {
    try {
      await vocabularyService.delete(id);
      addToast("Đã xóa từ vựng", "success");
      navigate("/vocabulary");
    } catch (err) {
      addToast(err.message || "Lỗi xóa từ vựng", "error");
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  if (!data || !data.vocabulary) return null;

  const { vocabulary, definitions = [], collections = [] } = data;
  const cefrStyle = CEFR_COLORS[vocabulary.cefr_level] || {};

  return (
    <>
      <Header
        title={vocabulary.word}
        actions={
          <div className="flex items-center gap-3">
            <Button variant="secondary" onClick={() => navigate("/vocabulary")}>
              ← Quay lại danh sách
            </Button>
            {!isEditing && (
              <>
                <Button variant="secondary" onClick={() => setIsEditing(true)}>
                  Chỉnh sửa
                </Button>
                <Button
                  variant="ghost"
                  onClick={() => setIsDeleting(true)}
                  className="text-red-600 hover:text-red-800"
                >
                  Xóa
                </Button>
              </>
            )}
          </div>
        }
      />

      <div className="p-6 max-w-4xl mx-auto">
        {isEditing ? (
          <WordForm
            initialData={data}
            collections={allCollections}
            assignedCollectionIds={collections.map((c) => c.id)}
            onSubmit={handleUpdate}
            onCancel={() => setIsEditing(false)}
            isSubmitting={isSaving}
          />
        ) : (
          <div className="flex flex-col gap-6">
            {/* Word Header Card */}
            <div className="card-taupe flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
              <div>
                <div className="flex items-center gap-3">
                  <h1 className="text-display font-display font-light text-ink">
                    {vocabulary.word}
                  </h1>
                  {vocabulary.audio_url && (
                    <button
                      onClick={() => handlePlayAudio(vocabulary.audio_url)}
                      className="w-9 h-9 rounded-full bg-eggshell border border-stone flex items-center justify-center hover:bg-stone/50 transition-colors"
                      title="Phát âm"
                    >
                      🔊
                    </button>
                  )}
                </div>

                {vocabulary.phonetic && (
                  <p className="text-body font-mono text-smoke mt-1">
                    {vocabulary.phonetic}
                  </p>
                )}
              </div>

              <div className="flex flex-wrap items-center gap-2">
                {vocabulary.part_of_speech && (
                  <span className="px-3 py-1 bg-eggshell text-ink font-medium rounded-pill text-body-sm border border-stone">
                    {vocabulary.part_of_speech}
                  </span>
                )}
                {vocabulary.cefr_level && (
                  <span
                    className={`px-3 py-1 rounded-pill text-body-sm font-medium ${cefrStyle.bg || "bg-stone"} ${cefrStyle.text || "text-graphite"}`}
                  >
                    CEFR: {vocabulary.cefr_level}
                  </span>
                )}
                {vocabulary.usage_register && (
                  <span className="px-3 py-1 bg-eggshell text-smoke rounded-pill text-body-sm border border-stone">
                    {vocabulary.usage_register}
                  </span>
                )}
              </div>
            </div>

            {/* Definitions */}
            <div className="card-taupe flex flex-col gap-4">
              <h2 className="text-subheading font-display font-light text-ink">
                Định nghĩa ({definitions.length})
              </h2>

              {definitions.length === 0 ? (
                <p className="text-smoke text-body-sm">
                  Chưa có định nghĩa nào cho từ này.
                </p>
              ) : (
                <div className="flex flex-col gap-4">
                  {definitions.map((def, idx) => (
                    <div
                      key={def.id || idx}
                      className="p-4 bg-eggshell border border-stone rounded-lg flex flex-col gap-2"
                    >
                      {def.definition_vi && (
                        <p className="text-body font-medium text-ink">
                          {def.definition_vi}
                        </p>
                      )}
                      {def.definition_en && (
                        <p className="text-body-sm text-smoke">
                          {def.definition_en}
                        </p>
                      )}
                      {def.example && (
                        <p className="text-body-sm text-ash italic border-l-2 border-stone pl-3 mt-1">
                          "{def.example}"
                        </p>
                      )}
                    </div>
                  ))}
                </div>
              )}
            </div>

            {/* Collections Assigned */}
            <div className="card-taupe flex flex-col gap-3">
              <div className="flex items-center justify-between">
                <h2 className="text-subheading font-display font-light text-ink">
                  Bộ sưu tập
                </h2>
                <Button
                  size="sm"
                  variant={collections.length === 0 ? "secondary" : "ghost"}
                  onClick={() => setIsEditing(true)}
                >
                  {collections.length === 0 ? "+ Gán vào bộ sưu tập" : "✏️ Chỉnh sửa"}
                </Button>
              </div>

              {collections.length === 0 ? (
                <p className="text-smoke text-body-sm">
                  Từ này chưa được gán vào bộ sưu tập nào. Nhấn "+ Gán vào bộ sưu tập" để phân loại.
                </p>
              ) : (
                <div className="flex flex-wrap gap-2">
                  {collections.map((col) => (
                    <span
                      key={col.id}
                      className="px-3 py-1 bg-eggshell border border-stone text-graphite rounded-pill text-body-sm font-medium"
                    >
                      📁 {col.name}
                    </span>
                  ))}
                </div>
              )}
            </div>

            {/* Meta Info */}
            <div className="flex items-center justify-between text-caption text-ash px-2">
              <span>
                Thêm vào ngày: {formatDate(vocabulary.created_at)}
              </span>
              {vocabulary.updated_at && (
                <span>
                  Cập nhật lần cuối: {formatDate(vocabulary.updated_at)}
                </span>
              )}
            </div>
          </div>
        )}
      </div>

      <ConfirmDialog
        isOpen={isDeleting}
        title="Xác nhận xóa từ vựng"
        message={`Bạn có chắc chắn muốn xóa từ "${vocabulary.word}" khỏi sổ tay không?`}
        confirmText="Xóa vĩnh viễn"
        variant="danger"
        onConfirm={handleDelete}
        onCancel={() => setIsDeleting(false)}
      />
    </>
  );
}
