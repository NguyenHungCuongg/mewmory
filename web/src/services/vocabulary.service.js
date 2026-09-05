import db from "../db/database";
import { PAGINATION } from "../utils/constants";

export const vocabularyService = {
  async create(vocabularyData, definitions = [], collectionIds = []) {
    const vocabId = crypto.randomUUID();
    const now = new Date().toISOString();

    const vocabulary = {
      id: vocabId,
      user_id: vocabularyData.user_id,
      word: vocabularyData.word.trim(),
      phonetic: vocabularyData.phonetic || null,
      audio_url: vocabularyData.audio_url || null,
      part_of_speech: vocabularyData.part_of_speech || null,
      cefr_level: vocabularyData.cefr_level || null,
      usage_register: vocabularyData.usage_register || null,
      created_at: now,
      updated_at: now,
      is_deleted: false,
    };

    const definitionRecords = definitions.map((def, index) => ({
      id: crypto.randomUUID(),
      vocabulary_id: vocabId,
      definition_en: def.definition_en || null,
      definition_vi: def.definition_vi || null,
      example: def.example || null,
      sort_order: index,
      created_at: now,
      updated_at: now,
      is_deleted: false,
    }));

    const collectionRecords = collectionIds.map((colId) => ({
      id: crypto.randomUUID(),
      vocabulary_id: vocabId,
      collection_id: colId,
      created_at: now,
      updated_at: now,
      is_deleted: false,
    }));

    await db.transaction(
      "rw",
      [
        db.vocabularies,
        db.definitions,
        db.vocabulary_collections,
        db.sync_queue,
      ],
      async () => {
        await db.vocabularies.put(vocabulary);
        if (definitionRecords.length > 0) {
          await db.definitions.bulkPut(definitionRecords);
        }
        if (collectionRecords.length > 0) {
          await db.vocabulary_collections.bulkPut(collectionRecords);
        }

        // Add to sync queue
        await db.sync_queue.add({
          table_name: "vocabularies",
          record_id: vocabId,
          operation: "CREATE",
          payload: vocabulary,
          created_at: now,
          synced: false,
        });

        for (const def of definitionRecords) {
          await db.sync_queue.add({
            table_name: "definitions",
            record_id: def.id,
            operation: "CREATE",
            payload: def,
            created_at: now,
            synced: false,
          });
        }

        for (const colRec of collectionRecords) {
          await db.sync_queue.add({
            table_name: "vocabulary_collections",
            record_id: colRec.id,
            operation: "CREATE",
            payload: colRec,
            created_at: now,
            synced: false,
          });
        }
      },
    );

    return {
      vocabulary,
      definitions: definitionRecords,
      collectionIds,
    };
  },

  async getAll(
    userId,
    {
      search = "",
      filters = {},
      sort = { field: "created_at", order: "desc" },
      offset = 0,
      limit = PAGINATION.DEFAULT_LIMIT,
    } = {},
  ) {
    let collection = db.vocabularies
      .where("user_id")
      .equals(userId)
      .and((v) => !v.is_deleted);

    let items = await collection.toArray();

    // Apply search
    if (search) {
      const searchLower = search.toLowerCase();
      // Also search in definitions
      const allDefinitions = await db.definitions
        .where("is_deleted")
        .equals(0)
        .toArray();
      const vocabIdsWithMatchingDefs = new Set(
        allDefinitions
          .filter(
            (d) =>
              (d.definition_vi &&
                d.definition_vi.toLowerCase().includes(searchLower)) ||
              (d.definition_en &&
                d.definition_en.toLowerCase().includes(searchLower)),
          )
          .map((d) => d.vocabulary_id),
      );

      items = items.filter(
        (v) =>
          v.word.toLowerCase().includes(searchLower) ||
          vocabIdsWithMatchingDefs.has(v.id),
      );
    }

    // Apply filters
    if (filters.cefr_level) {
      items = items.filter((v) => v.cefr_level === filters.cefr_level);
    }
    if (filters.part_of_speech) {
      items = items.filter((v) => v.part_of_speech === filters.part_of_speech);
    }
    if (filters.usage_register) {
      items = items.filter((v) => v.usage_register === filters.usage_register);
    }
    if (filters.collection_id) {
      const vcLinks = await db.vocabulary_collections
        .where("collection_id")
        .equals(filters.collection_id)
        .and((vc) => !vc.is_deleted)
        .toArray();
      const vocabIds = new Set(vcLinks.map((vc) => vc.vocabulary_id));
      items = items.filter((v) => vocabIds.has(v.id));
    }

    const total = items.length;

    // Sort
    items.sort((a, b) => {
      const aVal = a[sort.field] || "";
      const bVal = b[sort.field] || "";
      const comparison =
        typeof aVal === "string" ? aVal.localeCompare(bVal) : aVal - bVal;
      return sort.order === "desc" ? -comparison : comparison;
    });

    // Paginate
    items = items.slice(offset, offset + limit);

    // Attach definitions to each vocabulary
    for (const item of items) {
      item.definitions = await db.definitions
        .where("vocabulary_id")
        .equals(item.id)
        .and((d) => !d.is_deleted)
        .sortBy("sort_order");
    }

    return { items, total };
  },

  async getById(id) {
    const vocabulary = await db.vocabularies.get(id);
    if (!vocabulary || vocabulary.is_deleted) return null;

    const definitions = await db.definitions
      .where("vocabulary_id")
      .equals(id)
      .and((d) => !d.is_deleted)
      .sortBy("sort_order");

    const vcLinks = await db.vocabulary_collections
      .where("vocabulary_id")
      .equals(id)
      .and((vc) => !vc.is_deleted)
      .toArray();
    const collectionIds = vcLinks.map((vc) => vc.collection_id);
    const collections =
      collectionIds.length > 0
        ? await db.collections
            .where("id")
            .anyOf(collectionIds)
            .and((c) => !c.is_deleted)
            .toArray()
        : [];

    return { vocabulary, definitions, collections };
  },

  async update(id, updates) {
    const now = new Date().toISOString();
    const updated = { ...updates, updated_at: now };
    delete updated.id;

    await db.transaction("rw", [db.vocabularies, db.sync_queue], async () => {
      await db.vocabularies.update(id, updated);
      await db.sync_queue.add({
        table_name: "vocabularies",
        record_id: id,
        operation: "UPDATE",
        payload: updated,
        created_at: now,
        synced: false,
      });
    });

    return db.vocabularies.get(id);
  },

  async updateWithDetails(id, vocabUpdates, newDefinitions = [], collectionIds = []) {
    const now = new Date().toISOString();
    const updatedVocab = { ...vocabUpdates, updated_at: now };
    delete updatedVocab.id;

    await db.transaction(
      "rw",
      [
        db.vocabularies,
        db.definitions,
        db.vocabulary_collections,
        db.sync_queue,
      ],
      async () => {
        // 1. Update vocabulary
        await db.vocabularies.update(id, updatedVocab);
        await db.sync_queue.add({
          table_name: "vocabularies",
          record_id: id,
          operation: "UPDATE",
          payload: updatedVocab,
          created_at: now,
          synced: false,
        });

        // 2. Handle definitions: soft delete old ones, add/update new ones
        const existingDefs = await db.definitions
          .where("vocabulary_id")
          .equals(id)
          .toArray();

        for (const ed of existingDefs) {
          await db.definitions.update(ed.id, {
            is_deleted: true,
            updated_at: now,
          });
          await db.sync_queue.add({
            table_name: "definitions",
            record_id: ed.id,
            operation: "DELETE",
            payload: { is_deleted: true },
            created_at: now,
            synced: false,
          });
        }

        for (let i = 0; i < newDefinitions.length; i++) {
          const def = newDefinitions[i];
          const defId = def.id || crypto.randomUUID();
          const defRecord = {
            id: defId,
            vocabulary_id: id,
            definition_en: def.definition_en?.trim() || null,
            definition_vi: def.definition_vi?.trim() || null,
            example: def.example?.trim() || null,
            sort_order: i,
            created_at: def.created_at || now,
            updated_at: now,
            is_deleted: false,
          };
          await db.definitions.put(defRecord);
          await db.sync_queue.add({
            table_name: "definitions",
            record_id: defId,
            operation: "CREATE",
            payload: defRecord,
            created_at: now,
            synced: false,
          });
        }

        // 3. Handle collections
        const existingLinks = await db.vocabulary_collections
          .where("vocabulary_id")
          .equals(id)
          .and((l) => !l.is_deleted)
          .toArray();

        const currentLinkColIds = new Set(existingLinks.map((l) => l.collection_id));
        const targetColIds = new Set(collectionIds);

        // Remove unselected
        for (const link of existingLinks) {
          if (!targetColIds.has(link.collection_id)) {
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
          }
        }

        // Add newly selected
        for (const colId of collectionIds) {
          if (!currentLinkColIds.has(colId)) {
            const linkId = crypto.randomUUID();
            const linkRecord = {
              id: linkId,
              vocabulary_id: id,
              collection_id: colId,
              created_at: now,
              updated_at: now,
              is_deleted: false,
            };
            await db.vocabulary_collections.put(linkRecord);
            await db.sync_queue.add({
              table_name: "vocabulary_collections",
              record_id: linkId,
              operation: "CREATE",
              payload: linkRecord,
              created_at: now,
              synced: false,
            });
          }
        }
      },
    );

    return this.getById(id);
  },

  async delete(id) {
    const now = new Date().toISOString();

    await db.transaction(
      "rw",
      [
        db.vocabularies,
        db.definitions,
        db.vocabulary_collections,
        db.sync_queue,
      ],
      async () => {
        // Soft delete vocabulary
        await db.vocabularies.update(id, { is_deleted: true, updated_at: now });

        // Soft delete related definitions
        const defs = await db.definitions
          .where("vocabulary_id")
          .equals(id)
          .toArray();
        for (const def of defs) {
          await db.definitions.update(def.id, {
            is_deleted: true,
            updated_at: now,
          });
        }

        // Soft delete related collection links
        const vcLinks = await db.vocabulary_collections
          .where("vocabulary_id")
          .equals(id)
          .toArray();
        for (const vc of vcLinks) {
          await db.vocabulary_collections.update(vc.id, {
            is_deleted: true,
            updated_at: now,
          });
        }

        // Add to sync queue
        await db.sync_queue.add({
          table_name: "vocabularies",
          record_id: id,
          operation: "DELETE",
          payload: { is_deleted: true },
          created_at: now,
          synced: false,
        });
      },
    );
  },

  async checkDuplicate(userId, word) {
    const matches = await db.vocabularies
      .where("user_id")
      .equals(userId)
      .and(
        (v) =>
          !v.is_deleted && v.word.toLowerCase() === word.toLowerCase().trim(),
      )
      .toArray();

    return { count: matches.length, entries: matches };
  },
};
