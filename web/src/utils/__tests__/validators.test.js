import { describe, it, expect } from "vitest";
import { validateWord, validateEmail, validatePassword } from "../validators";

describe("validateWord", () => {
  it("rejects empty word", () => {
    expect(validateWord("")).toEqual({
      valid: false,
      error: "Vui lòng nhập từ vựng",
    });
  });

  it("accepts valid English word", () => {
    expect(validateWord("resilient")).toEqual({ valid: true });
  });

  it("accepts multi-word with spaces and hyphens", () => {
    expect(validateWord("don't")).toEqual({ valid: true });
    expect(validateWord("well-known")).toEqual({ valid: true });
  });

  it("rejects word with numbers", () => {
    const result = validateWord("abc123");
    expect(result.valid).toBe(false);
  });
});

describe("validateEmail", () => {
  it("accepts valid email", () => {
    expect(validateEmail("test@example.com")).toEqual({ valid: true });
  });

  it("rejects invalid email", () => {
    expect(validateEmail("not-an-email").valid).toBe(false);
  });
});

describe("validatePassword", () => {
  it("accepts password with 6+ chars", () => {
    expect(validatePassword("abcdef")).toEqual({ valid: true });
  });

  it("rejects short password", () => {
    expect(validatePassword("abc").valid).toBe(false);
  });
});
