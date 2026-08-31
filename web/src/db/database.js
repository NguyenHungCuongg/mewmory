import Dexie from "dexie";

const db = new Dexie("mewmory");

db.version(1).stores({
  vocabularies:
    "id, user_id, word, cefr_level, part_of_speech, usage_register, created_at, updated_at, is_deleted",
  definitions: "id, vocabulary_id, sort_order, updated_at, is_deleted",
  collections: "id, user_id, name, is_default, updated_at, is_deleted",
  vocabulary_collections:
    "id, vocabulary_id, collection_id, updated_at, is_deleted",
  user_settings: "id, user_id",
  sync_queue: "++id, table_name, record_id, operation, created_at, synced",
});

export default db;
