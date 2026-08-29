import { describe, it, expect } from "vitest";
import { CEFR_LEVELS, PARTS_OF_SPEECH, USAGE_REGISTERS } from "../constants";

describe("constants", () => {
  it("has 6 CEFR levels in order", () => {
    expect(CEFR_LEVELS).toEqual(["A1", "A2", "B1", "B2", "C1", "C2"]);
  });

  it("has standard parts of speech", () => {
    expect(PARTS_OF_SPEECH).toContain("noun");
    expect(PARTS_OF_SPEECH).toContain("verb");
    expect(PARTS_OF_SPEECH).toContain("adjective");
    expect(PARTS_OF_SPEECH.length).toBeGreaterThanOrEqual(8);
  });

  it("has usage registers", () => {
    expect(USAGE_REGISTERS).toContain("formal");
    expect(USAGE_REGISTERS).toContain("informal");
    expect(USAGE_REGISTERS).toContain("slang");
  });
});
