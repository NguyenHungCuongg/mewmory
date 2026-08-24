# Mewmory — API Specification

> **Version:** 1.0
> **Last Updated:** 2026-08-25
> **Related:** [PRD.md](file:///f:/Side%20Projects/mewmory/docs/PRD.md) | [SAD.md](file:///f:/Side%20Projects/mewmory/docs/SAD.md) | [Database_Schema.md](file:///f:/Side%20Projects/mewmory/docs/Database_Schema.md)
> **Status:** Draft — Pending Review

---

## 1. Tổng quan

### 1.1 API Types

| Type | Provider | Usage |
|---|---|---|
| **Supabase Client API** | Supabase JS SDK | CRUD trực tiếp vào PostgreSQL (RLS-protected) |
| **Supabase Edge Functions** | Supabase Edge (Deno) | AI proxy, Dictionary proxy |
| **Free Dictionary API** | dictionaryapi.dev | Lookup từ tiếng Anh |

### 1.2 Authentication

Tất cả API calls (trừ auth endpoints) yêu cầu JWT token trong header:

```
Authorization: Bearer <supabase_access_token>
```

---

## 2. Supabase Edge Functions

### 2.1 `POST /functions/v1/lookup-word`

**Mô tả:** Tra cứu từ vựng — gọi song song Dictionary API + AI API, merge kết quả trả về structured data.

**Request:**
```json
{
  "word": "resilient",
  "provider": "gemini",
  "model": "gemini-2.0-flash"
}
```

| Field | Type | Required | Description |
|---|---|---|---|
| `word` | string | ✅ | Từ tiếng Anh cần tra cứu |
| `provider` | string | ❌ | `"gemini"` \| `"openrouter"` (default: user's setting) |
| `model` | string | ❌ | Model cụ thể (default: provider's default model) |

**Response (200):**
```json
{
  "word": "resilient",
  "phonetic": "/rɪˈzɪl.i.ənt/",
  "audio_url": "https://api.dictionaryapi.dev/media/pronunciations/en/resilient-us.mp3",
  "meanings": [
    {
      "part_of_speech": "adjective",
      "cefr_level": "C1",
      "usage_register": "formal",
      "definitions": [
        {
          "definition_en": "able to quickly return to a previous good condition after problems",
          "definition_vi": "có khả năng phục hồi, kiên cường",
          "example": "She's a resilient girl — she won't be unhappy for long.",
          "synonyms": ["tough", "strong", "hardy"],
          "antonyms": ["fragile", "weak"]
        },
        {
          "definition_en": "(of a substance) able to return to its original shape after being bent, stretched, or pressed",
          "definition_vi": "đàn hồi, có tính đàn hồi",
          "example": "This rubber is extremely resilient.",
          "synonyms": ["elastic", "flexible"],
          "antonyms": ["rigid", "stiff"]
        }
      ]
    }
  ],
  "suggested_collections": ["Personality", "IELTS Writing"],
  "source": {
    "dictionary": true,
    "ai": true
  }
}
```

**Error Responses:**

| Code | Description |
|---|---|
| 400 | `{ "error": "Word is required" }` |
| 401 | `{ "error": "Unauthorized" }` |
| 404 | `{ "error": "Word not found in dictionary", "ai_only": true, ... }` — AI vẫn trả kết quả |
| 429 | `{ "error": "AI API rate limit exceeded. Try again later." }` |
| 500 | `{ "error": "Internal server error" }` |

**Fallback behavior:**
- Dictionary API fails → chỉ trả AI data, `source.dictionary = false`.
- AI API fails → chỉ trả Dictionary data, `source.ai = false`. Level/Usage/Vietnamese trống.
- Cả hai fails → 503 `{ "error": "All lookup services unavailable" }`.

---

### 2.2 `POST /functions/v1/ai-classify`

**Mô tả:** Phân loại từ vựng vào Collection bằng AI (gọi riêng khi cần reclassify).

**Request:**
```json
{
  "word": "resilient",
  "definitions_vi": ["có khả năng phục hồi", "đàn hồi"],
  "existing_collections": ["Travel", "Business", "Technology", "IELTS Writing"]
}
```

**Response (200):**
```json
{
  "suggested_collections": ["Personality", "IELTS Writing"],
  "new_collections": ["Personality"],
  "existing_matches": ["IELTS Writing"]
}
```

---

## 3. Supabase Client API (Direct Database Operations)

> [!NOTE]
> Các operations dưới đây sử dụng Supabase JS SDK (`@supabase/supabase-js`).
> RLS policies đảm bảo mỗi user chỉ truy cập data của mình.

### 3.1 Vocabularies

#### Create Vocabulary
```javascript
const { data, error } = await supabase
  .from('vocabularies')
  .insert({
    user_id: userId,
    word: 'resilient',
    phonetic: '/rɪˈzɪl.i.ənt/',
    part_of_speech: 'adjective',
    cefr_level: 'C1',
    usage_register: 'formal'
  })
  .select()
  .single();
```

#### Get Vocabularies (with filters)
```javascript
let query = supabase
  .from('vocabularies')
  .select(`
    *,
    definitions(*),
    vocabulary_collections(collection_id, collections(name))
  `)
  .eq('user_id', userId)
  .eq('is_deleted', false);

// Optional filters
if (cefrLevel) query = query.eq('cefr_level', cefrLevel);
if (partOfSpeech) query = query.eq('part_of_speech', partOfSpeech);
if (usageRegister) query = query.eq('usage_register', usageRegister);

// Search
if (searchTerm) query = query.ilike('word', `%${searchTerm}%`);

// Sort
query = query.order('created_at', { ascending: false });

// Pagination
query = query.range(offset, offset + limit - 1);

const { data, error } = await query;
```

#### Update Vocabulary
```javascript
const { data, error } = await supabase
  .from('vocabularies')
  .update({
    cefr_level: 'B2',
    usage_register: 'informal'
  })
  .eq('id', vocabularyId)
  .select()
  .single();
```

#### Soft Delete Vocabulary
```javascript
const { error } = await supabase
  .from('vocabularies')
  .update({ is_deleted: true })
  .eq('id', vocabularyId);
```

### 3.2 Definitions

#### Create Definitions (batch)
```javascript
const { data, error } = await supabase
  .from('definitions')
  .insert([
    {
      vocabulary_id: vocabId,
      definition_en: 'able to quickly return to a previous good condition',
      definition_vi: 'có khả năng phục hồi, kiên cường',
      example: "She's a resilient girl.",
      sort_order: 0
    },
    {
      vocabulary_id: vocabId,
      definition_en: 'able to return to its original shape',
      definition_vi: 'đàn hồi',
      example: 'This rubber is extremely resilient.',
      sort_order: 1
    }
  ])
  .select();
```

### 3.3 Collections

#### Create Collection
```javascript
const { data, error } = await supabase
  .from('collections')
  .insert({
    user_id: userId,
    name: 'IELTS Writing Task 2',
    description: 'Từ vựng cho IELTS Writing Task 2',
    is_ai_generated: false
  })
  .select()
  .single();
```

#### Get Collections with Word Count
```javascript
const { data, error } = await supabase
  .from('collections')
  .select(`
    *,
    vocabulary_collections(count)
  `)
  .eq('user_id', userId)
  .eq('is_deleted', false)
  .order('name');
```

### 3.4 Vocabulary-Collection Assignment

#### Assign Word to Collection
```javascript
const { error } = await supabase
  .from('vocabulary_collections')
  .insert({
    vocabulary_id: vocabId,
    collection_id: collectionId
  });
```

#### Remove Word from Collection
```javascript
const { error } = await supabase
  .from('vocabulary_collections')
  .update({ is_deleted: true })
  .eq('vocabulary_id', vocabId)
  .eq('collection_id', collectionId);
```

### 3.5 User Settings

#### Get Settings
```javascript
const { data, error } = await supabase
  .from('user_settings')
  .select('*')
  .eq('user_id', userId)
  .single();
```

#### Update Settings
```javascript
const { error } = await supabase
  .from('user_settings')
  .update({
    ai_provider: 'openrouter',
    ai_model: 'meta-llama/llama-3.1-8b-instruct:free',
    notification_mode: 'quiz'
  })
  .eq('user_id', userId);
```

### 3.6 Statistics (RPC calls)

```javascript
// Total word count
const { data: count } = await supabase.rpc('get_vocab_count', {
  p_user_id: userId
});

// Level distribution
const { data: levels } = await supabase.rpc('get_level_distribution', {
  p_user_id: userId
});

// Collection distribution
const { data: collections } = await supabase.rpc('get_collection_distribution', {
  p_user_id: userId
});

// Daily word count (streak)
const { data: daily } = await supabase.rpc('get_daily_word_count', {
  p_user_id: userId,
  p_days: 30
});
```

### 3.7 Duplicate Check

```javascript
const { data: duplicates } = await supabase.rpc('check_duplicate_word', {
  p_user_id: userId,
  p_word: 'resilient',
  p_definitions_vi: ['có khả năng phục hồi', 'đàn hồi']
});

if (duplicates && duplicates.length > 0) {
  // Show duplicate warning
}
```

---

## 4. Sync API

### 4.1 Push Changes (Client → Server)

**Process sync queue entries sequentially:**

```javascript
async function pushChanges(syncQueue) {
  for (const entry of syncQueue) {
    const { table_name, record_id, operation, payload } = entry;

    switch (operation) {
      case 'CREATE':
        await supabase.from(table_name).upsert(payload);
        break;
      case 'UPDATE':
        await supabase.from(table_name).update(payload).eq('id', record_id);
        break;
      case 'DELETE':
        await supabase.from(table_name).update({ is_deleted: true }).eq('id', record_id);
        break;
    }

    // Mark as synced in local queue
    await db.sync_queue.update(entry.id, { synced: true });
  }
}
```

### 4.2 Pull Changes (Server → Client)

```javascript
async function pullChanges(lastSyncTimestamp) {
  const tables = ['vocabularies', 'definitions', 'collections', 'vocabulary_collections', 'user_settings'];

  for (const table of tables) {
    const { data } = await supabase
      .from(table)
      .select('*')
      .gt('updated_at', lastSyncTimestamp);

    if (data && data.length > 0) {
      await db[table].bulkPut(data);
    }
  }

  // Update last sync timestamp
  localStorage.setItem('last_sync', new Date().toISOString());
}
```

---

## 5. External API Reference

### 5.1 Free Dictionary API

**Endpoint:** `GET https://api.dictionaryapi.dev/api/v2/entries/en/{word}`

**Response structure (simplified):**
```json
[
  {
    "word": "resilient",
    "phonetic": "/rɪˈzɪl.i.ənt/",
    "phonetics": [
      {
        "text": "/rɪˈzɪl.i.ənt/",
        "audio": "https://...mp3"
      }
    ],
    "meanings": [
      {
        "partOfSpeech": "adjective",
        "definitions": [
          {
            "definition": "Able to recover from setbacks.",
            "example": "She is very resilient.",
            "synonyms": ["tough"],
            "antonyms": ["fragile"]
          }
        ]
      }
    ]
  }
]
```

> [!IMPORTANT]
> API này **KHÔNG** cung cấp: CEFR level, usage register, nghĩa tiếng Việt.
> Các field này phải lấy từ AI API.

### 5.2 AI API Prompt Template

```
You are a vocabulary analysis assistant. Given an English word and its dictionary data, provide additional information in JSON format.

Word: "{word}"
Dictionary data: {dictionary_response}

Return a JSON object with:
{
  "cefr_level": "A1|A2|B1|B2|C1|C2",
  "usage_register": "formal|informal|slang|neutral|vulgar|technical",
  "vietnamese_definitions": [
    {
      "original_en": "<matching English definition>",
      "translation_vi": "<Vietnamese translation>",
      "example_vi": "<Vietnamese context if helpful>"
    }
  ],
  "additional_examples": ["<extra example sentences if dictionary lacks them>"],
  "suggested_collections": ["<topic categories like Travel, Business, etc.>"]
}

Rules:
- CEFR level should reflect the word's difficulty for learners.
- Vietnamese translations should be natural and contextual, not literal.
- Suggested collections should be broad topic categories.
- Return ONLY valid JSON, no markdown or explanation.
```

---

## 6. Rate Limits & Quotas

| Service | Limit | Impact |
|---|---|---|
| Free Dictionary API | No known rate limit | Safe for our usage |
| Gemini API (free) | 15 RPM, 1M tokens/min | ~10 lookups/min → OK |
| OpenRouter (free models) | Varies by model | Backup option |
| Supabase Edge Functions | 500K/month | ~3K/month estimated → OK |
| Supabase Database | 500MB | ~20MB estimated → OK |
