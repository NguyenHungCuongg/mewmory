import { useState, useEffect } from "react";
import { useTranslation } from "react-i18next";
import Modal from "../common/Modal";
import Input from "../common/Input";
import Button from "../common/Button";

export default function CollectionForm({
  isOpen,
  onClose,
  onSubmit,
  initialData = null,
  isSubmitting = false,
}) {
  const { t } = useTranslation("collection");
  const [name, setName] = useState("");
  const [description, setDescription] = useState("");
  const [error, setError] = useState("");

  useEffect(() => {
    if (initialData) {
      setName(initialData.name || "");
      setDescription(initialData.description || "");
    } else {
      setName("");
      setDescription("");
    }
    setError("");
  }, [initialData, isOpen]);

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!name.trim()) {
      setError(t("form.nameRequired"));
      return;
    }

    onSubmit({
      name: name.trim(),
      description: description.trim() || null,
    });
  };

  return (
    <Modal
      isOpen={isOpen}
      onClose={onClose}
      title={initialData ? t("form.editTitle") : t("form.createTitle")}
    >
      <form onSubmit={handleSubmit} className="flex flex-col gap-4">
        <Input
          id="collection-name"
          label={t("form.nameLabel")}
          placeholder={t("form.namePlaceholder")}
          value={name}
          onChange={(e) => {
            setName(e.target.value);
            if (error) setError("");
          }}
          error={error}
          autoFocus
        />

        <div className="flex flex-col gap-1.5">
          <label className="text-body-sm text-graphite font-medium">
            {t("form.descriptionLabel")}
          </label>
          <textarea
            rows={3}
            placeholder={t("form.descriptionPlaceholder")}
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            className="w-full px-3 py-2 rounded-lg border border-stone bg-eggshell text-body placeholder:text-ash focus:outline-none focus:border-ink resize-none"
          />
        </div>

        <div className="flex justify-end gap-3 mt-4 pt-4 border-t border-stone">
          <Button type="button" variant="secondary" onClick={onClose}>
            {t("form.cancel")}
          </Button>
          <Button type="submit" disabled={isSubmitting}>
            {isSubmitting
              ? t("form.saving")
              : initialData
                ? t("form.save")
                : t("form.create")}
          </Button>
        </div>
      </form>
    </Modal>
  );
}

