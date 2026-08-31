import { describe, it, expect, beforeEach } from "vitest";
import "fake-indexeddb/auto";
import db from "../../db/database";
import { settingsService } from "../settings.service";

const TEST_USER_ID = "settings-user-123";

beforeEach(async () => {
  await db.user_settings.clear();
  await db.sync_queue.clear();
});

describe("settingsService", () => {
  it("get creates default settings when none exist", async () => {
    const settings = await settingsService.get(TEST_USER_ID);
    expect(settings).toBeDefined();
    expect(settings.user_id).toBe(TEST_USER_ID);
    expect(settings.ai_provider).toBe("gemini");
    expect(settings.notification_mode).toBe("gentle");

    const queue = await db.sync_queue.toArray();
    expect(queue.some((q) => q.table_name === "user_settings")).toBe(true);
  });

  it("update modifies existing settings and enqueues sync", async () => {
    await settingsService.get(TEST_USER_ID);

    const updated = await settingsService.update(TEST_USER_ID, {
      ai_provider: "openrouter",
      notification_enabled: true,
    });

    expect(updated.ai_provider).toBe("openrouter");
    expect(updated.notification_enabled).toBe(true);

    const queue = await db.sync_queue.toArray();
    expect(
      queue.some(
        (q) => q.table_name === "user_settings" && q.operation === "UPDATE",
      ),
    ).toBe(true);
  });
});
