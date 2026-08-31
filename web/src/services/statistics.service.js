import db from "../db/database";
import { CEFR_LEVELS } from "../utils/constants";

export const statisticsService = {
  async getTotalCount(userId) {
    if (!userId) return 0;
    return db.vocabularies
      .where("user_id")
      .equals(userId)
      .and((v) => !v.is_deleted)
      .count();
  },

  async getLevelDistribution(userId) {
    if (!userId) return [];
    const vocabularies = await db.vocabularies
      .where("user_id")
      .equals(userId)
      .and((v) => !v.is_deleted)
      .toArray();

    const counts = {};
    for (const level of CEFR_LEVELS) {
      counts[level] = 0;
    }
    counts["Unranked"] = 0;

    for (const v of vocabularies) {
      if (v.cefr_level && counts[v.cefr_level] !== undefined) {
        counts[v.cefr_level]++;
      } else {
        counts["Unranked"]++;
      }
    }

    return Object.entries(counts)
      .filter(([_, count]) => count > 0)
      .map(([level, count]) => ({
        level,
        count,
      }));
  },

  async getCollectionDistribution(userId) {
    if (!userId) return [];
    const collections = await db.collections
      .where("user_id")
      .equals(userId)
      .and((c) => !c.is_deleted)
      .toArray();

    const result = [];
    for (const col of collections) {
      const links = await db.vocabulary_collections
        .where("collection_id")
        .equals(col.id)
        .and((vc) => !vc.is_deleted)
        .toArray();

      result.push({
        name: col.name,
        count: links.length,
      });
    }

    return result.sort((a, b) => b.count - a.count);
  },

  async getDailyWordCount(userId, days = 14) {
    if (!userId) return [];
    const vocabularies = await db.vocabularies
      .where("user_id")
      .equals(userId)
      .and((v) => !v.is_deleted)
      .toArray();

    // Generate dates for the last `days` days
    const dailyMap = {};
    const today = new Date();

    for (let i = days - 1; i >= 0; i--) {
      const d = new Date(today);
      d.setDate(d.getDate() - i);
      const dateStr = d.toISOString().split("T")[0];
      const displayDate = `${d.getDate()}/${d.getMonth() + 1}`;
      dailyMap[dateStr] = { date: displayDate, fullDate: dateStr, count: 0 };
    }

    for (const v of vocabularies) {
      if (v.created_at) {
        const vocabDate = v.created_at.split("T")[0];
        if (dailyMap[vocabDate]) {
          dailyMap[vocabDate].count++;
        }
      }
    }

    return Object.values(dailyMap);
  },

  async getRandomWord(userId, collectionIds = null) {
    if (!userId) return null;

    let vocabularies = [];
    if (collectionIds && collectionIds.length > 0) {
      const links = await db.vocabulary_collections
        .where("collection_id")
        .anyOf(collectionIds)
        .and((vc) => !vc.is_deleted)
        .toArray();
      const vocabIds = [...new Set(links.map((l) => l.vocabulary_id))];
      if (vocabIds.length > 0) {
        vocabularies = await db.vocabularies
          .where("id")
          .anyOf(vocabIds)
          .and((v) => !v.is_deleted)
          .toArray();
      }
    } else {
      vocabularies = await db.vocabularies
        .where("user_id")
        .equals(userId)
        .and((v) => !v.is_deleted)
        .toArray();
    }

    if (vocabularies.length === 0) return null;

    const randomIndex = Math.floor(Math.random() * vocabularies.length);
    const chosen = vocabularies[randomIndex];

    // Attach definitions
    chosen.definitions = await db.definitions
      .where("vocabulary_id")
      .equals(chosen.id)
      .and((d) => !d.is_deleted)
      .sortBy("sort_order");

    return chosen;
  },
};
