import { useState, useEffect } from "react";
import { useTranslation } from "react-i18next";
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
import { IconFolder } from "../components/common/Icons";

export default function CollectionsPage() {
  const { t } = useTranslation("collection");
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
        addToast(t("toasts.updateSuccess"), "success");
      } else {
        await addCollection({
          ...formData,
          user_id: user.id,
        });
        addToast(t("toasts.createSuccess"), "success");
      }
      setIsFormOpen(false);
    } catch (err) {
      addToast(err.message || t("toasts.errorAction"), "error");
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleDelete = async () => {
    if (!deletingCollection) return;
    try {
      await deleteCollection(deletingCollection.id);
      addToast(t("toasts.deleteSuccess"), "success");
      setDeletingCollection(null);
    } catch (err) {
      addToast(err.message || t("toasts.errorDelete"), "error");
    }
  };

  return (
    <>
      <Header
        title={t("title")}
        actions={
          <Button onClick={handleOpenCreate}>{t("createCollection")}</Button>
        }
      />

      <div className="p-6 max-w-5xl mx-auto">
        {isLoading && items.length === 0 ? (
          <div className="flex items-center justify-center py-20">
            <LoadingSpinner size="lg" />
          </div>
        ) : items.length === 0 ? (
          <EmptyState
            icon={<IconFolder className="w-7 h-7 text-smoke" />}
            title={t("empty.title")}
            description={t("empty.description")}
            action={
              <Button onClick={handleOpenCreate}>
                {t("createFirst")}
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
        title={t("deleteConfirm.title")}
        message={t("deleteConfirm.message", { name: deletingCollection?.name })}
        confirmText={t("deleteConfirm.confirm")}
        variant="danger"
        onConfirm={handleDelete}
        onCancel={() => setDeletingCollection(null)}
      />
    </>
  );
}

