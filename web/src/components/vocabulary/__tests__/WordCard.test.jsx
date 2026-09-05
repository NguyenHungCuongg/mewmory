import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import { BrowserRouter } from "react-router-dom";
import WordCard from "../WordCard";

describe("WordCard component", () => {
  const mockVocab = {
    id: "vocab-1",
    word: "banana",
    phonetic: "/bə'nɑːnə/",
    part_of_speech: "noun",
    cefr_level: "A1",
    definitions: [
      {
        id: "def-1",
        definition_vi: "Quả chuối",
        definition_en: "A curved yellow fruit",
        example: "Monkeys love bananas.",
      },
    ],
  };

  it("renders word title, phonetic, badges and definitions", () => {
    render(
      <BrowserRouter>
        <WordCard vocabulary={mockVocab} />
      </BrowserRouter>,
    );

    expect(screen.getByText("banana")).toBeInTheDocument();
    expect(screen.getByText("/bə'nɑːnə/")).toBeInTheDocument();
    expect(screen.getByText("noun")).toBeInTheDocument();
    expect(screen.getByText("A1")).toBeInTheDocument();
    expect(screen.getByText("Quả chuối")).toBeInTheDocument();
    expect(screen.getByText("A curved yellow fruit")).toBeInTheDocument();
    expect(screen.getByText('"Monkeys love bananas."')).toBeInTheDocument();
  });
});
