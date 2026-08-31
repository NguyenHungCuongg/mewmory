import db from "../db/database";

export const collectionService = {
  async create(data) {
    const id = crypto.randomUUID();
    const now = new Date().toISOString();

    const collection = {
      id,
      user_id: data.user_id,
      name: data.name.trim(),
      description: data.description?.trim() || null,
      is_default: data.is_default || false,
      is_ai_generated: data.is_ai_generated || false,
      created_at: now,
      updated_at: now,
      is_deleted: false,
    };

    await db.transaction("rw", [db.collections, db.sync_queue], async () => {
      await db.collections.put(collection);
      await db.sync_queue.add({
        table_name: "collections",
        record_id: id,
        operation: "CREATE",
        payload: collection,
        created_at: now,
        synced: false,
      });
    });

    return collection;
  },

  async getAll(userId) {
    const collections = await db.collections
      .where("user_id")
      .equals(userId)
      .and((c) => !c.is_deleted)
      .toArray();

    // Attach word count
    for (const col of collections) {
      const links = await db.vocabulary_collections
        .where("collection_id")
        .equals(col.id)
        .and((vc) => !vc.is_deleted)
        .toArray();
      col.word_count = links.length;
    }

    // Sort: default first, then alphabetically
    collections.sort((a, b) => {
      if (a.is_default && !b.is_default) return -1;
      if (!a.is_default && b.is_default) return 1;
      return a.name.localeCompare(b.name);
    });

    return { items: collections };
  },

  async getById(id) {
    const collection = await db.collections.get(id);
    if (!collection || collection.is_deleted) return null;

    const vcLinks = await db.vocabulary_collections
      .where("collection_id")
      .equals(id)
      .and((vc) => !vc.is_deleted)
      .toArray();
    const vocabIds = vcLinks.map((vc) => vc.vocabulary_id);

    let vocabularies = [];
    if (vocabIds.length > 0) {
      vocabularies = await db.vocabularies
        .where("id")
        .anyOf(vocabIds)
        .and((v) => !v.is_deleted)
        .toArray();

      for (const vocab of vocabularies) {
        vocab.definitions = await db.definitions
          .where("vocabulary_id")
          .equals(vocab.id)
          .and((d) => !d.is_deleted)
          .sortBy("sort_order");
      }
    }

    return { collection, vocabularies };
  },

  async update(id, updates) {
    const now = new Date().toISOString();
    const updated = { ...updates, updated_at: now };
    delete updated.id;

    await db.transaction("rw", [db.collections, db.sync_queue], async () => {
      await db.collections.update(id, updated);
      await db.sync_queue.add({
        table_name: "collections",
        record_id: id,
        operation: "UPDATE",
        payload: updated,
        created_at: now,
        synced: false,
      });
    });

    return db.collections.get(id);
  },

  async delete(id) {
    const now = new Date().toISOString();

    await db.transaction(
      "rw",
      [db.collections, db.vocabulary_collections, db.sync_queue],
      async () => {
        await db.collections.update(id, { is_deleted: true, updated_at: now });

        const vcLinks = await db.vocabulary_collections
          .where("collection_id")
          .equals(id)
          .toArray();
        for (const vc of vcLinks) {
          await db.vocabulary_collections.update(vc.id, {
            is_deleted: true,
            updated_at: now,
          });
        }

        await db.sync_queue.add({
          table_name: "collections",
          record_id: id,
          operation: "DELETE",
          payload: { is_deleted: true },
          created_at: now,
          synced: false,
        });
      },
    );
  },

  async assignWord(vocabularyId, collectionId) {
    const id = crypto.randomUUID();
    const now = new Date().toISOString();

    const link = {
      id,
      vocabulary_id: vocabularyId,
      collection_id: collectionId,
      created_at: now,
      updated_at: now,
      is_deleted: false,
    };

    await db.transaction(
      "rw",
      [db.vocabulary_collections, db.sync_queue],
      async () => {
        await db.vocabulary_collections.put(link);
        await db.sync_queue.add({
          table_name: "vocabulary_collections",
          record_id: id,
          operation: "CREATE",
          payload: link,
          created_at: now,
          synced: false,
        });
      },
    );
  },

  async removeWord(vocabularyId, collectionId) {
    const now = new Date().toISOString();

    const link = await db.vocabulary_collections
      .where("vocabulary_id")
      .equals(vocabularyId)
      .and((vc) => vc.collection_id === collectionId && !vc.is_deleted)
      .first();

    if (!link) return;

    await db.transaction(
      "rw",
      [db.vocabulary_collections, db.sync_queue],
      async () => {
        await db.vocabulary_collections.update(link.id, {
          is_deleted: true,
          updated_at: now,
        });
        await db.sync_queue.add({
          table_name: "vocabulary_collections",
          record_id: link.id,
          operation: "DELETE",
          payload: { is_deleted: true },
          created_at: now,
          synced: false,
        });
      },
    );
  },
};
