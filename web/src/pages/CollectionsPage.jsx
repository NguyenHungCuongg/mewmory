import { useState, useEffect } from "react";
import { useAuthStore } from "../stores/auth.store";
import { useCollectionStore } from "../stores/collection.store";
import { useUIStore } from "../stores/ui.store";
import Header from "../components/layout/Header";
import Button from "../components/common/Button";
import LoadingSpinner from "../components/common/LoadingSpinner";
import ConfirmDialog from "../components/common/ConfirmDialog";
import CollectionCard from "../components/collection/CollectionCard";
import CollectionForm from "../components/collection/CollectionForm";
import EmptyState from "../components/common/EmptyState";

export default function CollectionsPage() {
  const { user } = useAuthStore();
  const { items, isLoading, fetchCollections, addCollection, updateCollection, deleteCollection } =
    useCollectionStore();
  const addToast = useUIStore((s) => s.addToast);

  const [isFormOpen, setIsFormOpen] = useState(false);
  const [editingCollection, setEditingCollection] = useState(null);
  const [deletingCollection, setDeletingCollection] = useState(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    if (user) {
      fetchCollections(user.id);
    }
  }, [user, fetchCollections]);

  const handleOpenCreate = () => {
    setEditingCollection(null);
    setIsFormOpen(true);
  };

  const handleOpenEdit = (col) => {
    setEditingCollection(col);
    setIsFormOpen(true);
  };

  const handleSubmitForm = async (formData) => {
    setIsSubmitting(true);
    try {
      if (editingCollection) {
        await updateCollection(editingCollection.id, formData);
        addToast("Đã cập nhật bộ sưu tập!", "success");
      } else {
        await addCollection({
          ...formData,
          user_id: user.id,
        });
        addToast("Đã tạo bộ sưu tập mới!", "success");
      }
      setIsFormOpen(false);
    } catch (err) {
      addToast(err.message || "Lỗi xử lý bộ sưu tập", "error");
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDelete = async () => {
    if (!deletingCollection) return;
    try {
      await deleteCollection(deletingCollection.id);
      addToast("Đã xóa bộ sưu tập", "success");
      setDeletingCollection(null);
    } catch (err) {
      addToast(err.message || "Lỗi xóa bộ sưu tập", "error");
    }
  };

  return (
    <>
      <Header
        title="Bộ sưu tập"
        actions={
          <Button onClick={handleOpenCreate}>+ Tạo bộ sưu tập</Button>
        }
      />

      <div className="p-6 max-w-5xl mx-auto">
        {isLoading && items.length === 0 ? (
          <div className="flex items-center justify-center py-20">
            <LoadingSpinner size="lg" />
          </div>
        ) : items.length === 0 ? (
          <EmptyState
            icon="📁"
            title="Chưa có bộ sưu tập nào"
            description="Nhóm từ vựng của bạn theo chủ đề, kỳ thi hoặc sở thích cá nhân để dễ dàng ôn tập."
            action={
              <Button onClick={handleOpenCreate}>
                + Tạo bộ sưu tập đầu tiên
              </Button>
            }
          />
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 animate-fade-in">
            {items.map((col) => (
              <CollectionCard
                key={col.id}
                collection={col}
                onEdit={handleOpenEdit}
                onDelete={setDeletingCollection}
              />
            ))}
          </div>
        )}
      </div>

      <CollectionForm
        isOpen={isFormOpen}
        onClose={() => setIsFormOpen(false)}
        onSubmit={handleSubmitForm}
        initialData={editingCollection}
        isSubmitting={isSubmitting}
      />

      <ConfirmDialog
        isOpen={!!deletingCollection}
        title="Xác nhận xóa bộ sưu tập"
        message={`Bạn có chắc muốn xóa bộ sưu tập "${deletingCollection?.name}"? Các từ vựng bên trong sẽ không bị xóa.`}
        confirmText="Xóa"
        variant="danger"
        onConfirm={handleDelete}
        onCancel={() => setDeletingCollection(null)}
      />
    </>
  );
}
