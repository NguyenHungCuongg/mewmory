import { describe, it, expect } from "vitest";
import { formatDate, formatRelativeTime, truncateText } from "../formatters";

describe("formatDate", () => {
  it("returns empty string for falsy input", () => {
    expect(formatDate(null)).toBe("");
    expect(formatDate(undefined)).toBe("");
    expect(formatDate("")).toBe("");
  });

  it("formats a valid ISO date string", () => {
    const result = formatDate("2026-08-25T10:00:00Z");
    expect(result).toBeTruthy();
    expect(typeof result).toBe("string");
  });
});

describe("formatRelativeTime", () => {
  it('returns "Vừa xong" for just now', () => {
    const now = new Date().toISOString();
    expect(formatRelativeTime(now)).toBe("Vừa xong");
  });

  it("returns empty string for falsy input", () => {
    expect(formatRelativeTime(null)).toBe("");
  });
});

describe("truncateText", () => {
  it("returns text unchanged if shorter than max", () => {
    expect(truncateText("hello", 10)).toBe("hello");
  });

  it("truncates text with ellipsis", () => {
    expect(truncateText("hello world foo bar", 10)).toBe("hello worl...");
  });

  it("handles null/undefined", () => {
    expect(truncateText(null)).toBe("");
    expect(truncateText(undefined)).toBe("");
  });
});
