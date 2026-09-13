import { describe, it, expect, vi } from "vitest";
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import MeaningSelector from "../MeaningSelector";

describe("MeaningSelector", () => {
  const mockMeanings = [
    {
      part_of_speech: "noun",
      cefr_level: "B1",
      usage_register: "neutral",
      definitions: [
        {
          definition_en: "A place to which one is journeying.",
          definition_vi: "Nơi đến, đích đến",
          example: "We reached our destination.",
        },
        {
          definition_en: "The purpose for which something is destined.",
          definition_vi: null,
          example: null,
        },
      ],
    },
    {
      part_of_speech: "verb",
      cefr_level: "C1",
      definitions: [
        {
          definition_en: "To design or destine.",
          definition_vi: "Dành riêng, định đoạt",
          example: null,
        },
      ],
    },
  ];

  it("renders empty message when meanings is empty", () => {
    render(<MeaningSelector meanings={[]} selectedMeanings={{}} />);
    expect(screen.getByText("Không tìm thấy nghĩa nào.")).toBeInTheDocument();
  });

  it("renders parts of speech, CEFR level, definitions, and selection count", () => {
    const selectedMeanings = {
      "0-0": { meaningIdx: 0, defIdx: 0 },
    };
    render(
      <MeaningSelector
        meanings={mockMeanings}
        selectedMeanings={selectedMeanings}
      />,
    );

    expect(screen.getByText("noun")).toBeInTheDocument();
    expect(screen.getByText("verb")).toBeInTheDocument();
    expect(screen.getByText("B1")).toBeInTheDocument();
    expect(screen.getByText("C1")).toBeInTheDocument();
    expect(
      screen.getByText("A place to which one is journeying."),
    ).toBeInTheDocument();
    expect(screen.getByDisplayValue("Nơi đến, đích đến")).toBeInTheDocument();
    expect(screen.getByText(/Đã chọn:/)).toBeInTheDocument();
  });

  it("toggles definition selection when checkbox is clicked", () => {
    const onSelectionChange = vi.fn();
    render(
      <MeaningSelector
        meanings={mockMeanings}
        selectedMeanings={{ "0-0": { meaningIdx: 0, defIdx: 0 } }}
        onSelectionChange={onSelectionChange}
      />,
    );

    const checkboxes = screen.getAllByRole("checkbox");
    // Click unselected checkbox (0-1)
    fireEvent.click(checkboxes[1]);
    expect(onSelectionChange).toHaveBeenCalledWith({
      "0-0": { meaningIdx: 0, defIdx: 0 },
      "0-1": { meaningIdx: 0, defIdx: 1 },
    });

    // Click already selected checkbox (0-0)
    fireEvent.click(checkboxes[0]);
    expect(onSelectionChange).toHaveBeenCalledWith({});
  });

  it("bulk selects and deselects all definitions", () => {
    const onSelectionChange = vi.fn();
    const { rerender } = render(
      <MeaningSelector
        meanings={mockMeanings}
        selectedMeanings={{}}
        onSelectionChange={onSelectionChange}
      />,
    );

    // Click "Chọn tất cả"
    const selectAllBtn = screen.getByText("Chọn tất cả");
    fireEvent.click(selectAllBtn);
    expect(onSelectionChange).toHaveBeenCalledWith({
      "0-0": { meaningIdx: 0, defIdx: 0 },
      "0-1": { meaningIdx: 0, defIdx: 1 },
      "1-0": { meaningIdx: 1, defIdx: 0 },
    });

    // When all are selected, button switches to "Bỏ chọn tất cả"
    const allSelected = {
      "0-0": { meaningIdx: 0, defIdx: 0 },
      "0-1": { meaningIdx: 0, defIdx: 1 },
      "1-0": { meaningIdx: 1, defIdx: 0 },
    };
    rerender(
      <MeaningSelector
        meanings={mockMeanings}
        selectedMeanings={allSelected}
        onSelectionChange={onSelectionChange}
      />,
    );

    const deselectAllBtn = screen.getByText("Bỏ chọn tất cả");
    fireEvent.click(deselectAllBtn);
    expect(onSelectionChange).toHaveBeenCalledWith({});
  });

  it("allows inline editing of definition_vi and example", () => {
    const onMeaningsChange = vi.fn();
    render(
      <MeaningSelector
        meanings={mockMeanings}
        selectedMeanings={{}}
        onMeaningsChange={onMeaningsChange}
      />,
    );

    const viInput = screen.getByDisplayValue("Nơi đến, đích đến");
    fireEvent.change(viInput, { target: { value: "Điểm đến du lịch" } });

    expect(onMeaningsChange).toHaveBeenCalledWith(
      expect.arrayContaining([
        expect.objectContaining({
          definitions: expect.arrayContaining([
            expect.objectContaining({ definition_vi: "Điểm đến du lịch" }),
          ]),
        }),
      ]),
    );

    const exInput = screen.getByDisplayValue("We reached our destination.");
    fireEvent.change(exInput, { target: { value: "Paris is our final destination." } });

    expect(onMeaningsChange).toHaveBeenCalledWith(
      expect.arrayContaining([
        expect.objectContaining({
          definitions: expect.arrayContaining([
            expect.objectContaining({
              example: "Paris is our final destination.",
            }),
          ]),
        }),
      ]),
    );
  });

  it("adds a new custom definition when '+ Thêm nghĩa' is clicked", () => {
    const onMeaningsChange = vi.fn();
    const onSelectionChange = vi.fn();
    render(
      <MeaningSelector
        meanings={mockMeanings}
        selectedMeanings={{}}
        onMeaningsChange={onMeaningsChange}
        onSelectionChange={onSelectionChange}
      />,
    );

    const addButtons = screen.getAllByText("+ Thêm nghĩa");
    fireEvent.click(addButtons[0]);

    // Meaning 0 originally had 2 definitions, now should have 3
    expect(onMeaningsChange).toHaveBeenCalledWith(
      expect.arrayContaining([
        expect.objectContaining({
          part_of_speech: "noun",
          definitions: expect.arrayContaining([
            expect.objectContaining({ isCustom: true }),
          ]),
        }),
      ]),
    );

    // New definition index 2 should be automatically selected
    expect(onSelectionChange).toHaveBeenCalledWith({
      "0-2": { meaningIdx: 0, defIdx: 2 },
    });
  });

  it("deletes a definition when ✕ button is clicked and shifts selection indices", () => {
    const onMeaningsChange = vi.fn();
    const onSelectionChange = vi.fn();
    const selected = {
      "0-0": { meaningIdx: 0, defIdx: 0 },
      "0-1": { meaningIdx: 0, defIdx: 1 },
      "1-0": { meaningIdx: 1, defIdx: 0 },
    };

    render(
      <MeaningSelector
        meanings={mockMeanings}
        selectedMeanings={selected}
        onMeaningsChange={onMeaningsChange}
        onSelectionChange={onSelectionChange}
      />,
    );

    const deleteButtons = screen.getAllByTitle("Xóa định nghĩa này");
    // Delete definition 0 of meaning 0
    fireEvent.click(deleteButtons[0]);

    expect(onMeaningsChange).toHaveBeenCalled();
    // In selectedMeanings: 0-0 is removed, 0-1 becomes 0-0, 1-0 stays 1-0
    expect(onSelectionChange).toHaveBeenCalledWith({
      "0-0": { meaningIdx: 0, defIdx: 0 },
      "1-0": { meaningIdx: 1, defIdx: 0 },
    });
  });

  it("renders 'Dịch' for definitions without definition_vi and 'Dịch lại' for definitions with definition_vi", () => {
    render(
      <MeaningSelector
        meanings={mockMeanings}
        selectedMeanings={{}}
        word="destination"
      />,
    );

    const translateButtons = screen.getAllByRole("button", {
      name: /dịch/i,
    });
    expect(translateButtons.length).toBe(3);
    expect(translateButtons[0]).toHaveTextContent("Dịch lại");
    expect(translateButtons[1]).toHaveTextContent("Dịch");
    expect(translateButtons[2]).toHaveTextContent("Dịch lại");
  });

  it("calls onTranslateDefinition and updates meaning on success", async () => {
    const onMeaningsChange = vi.fn();
    const mockTranslate = vi.fn().mockResolvedValue("Mục đích hoặc đích đến");

    render(
      <MeaningSelector
        meanings={mockMeanings}
        selectedMeanings={{}}
        word="destination"
        onMeaningsChange={onMeaningsChange}
        onTranslateDefinition={mockTranslate}
      />,
    );

    const translateButtons = screen.getAllByRole("button", {
      name: /dịch/i,
    });
    // Click "Dịch" on the 2nd definition
    fireEvent.click(translateButtons[1]);

    expect(mockTranslate).toHaveBeenCalledWith({
      text: "The purpose for which something is destined.",
      partOfSpeech: "noun",
      word: "destination",
    });

    await waitFor(() => {
      expect(onMeaningsChange).toHaveBeenCalledWith(
        expect.arrayContaining([
          expect.objectContaining({
            definitions: expect.arrayContaining([
              expect.objectContaining({
                definition_vi: "Mục đích hoặc đích đến",
              }),
            ]),
          }),
        ]),
      );
    });
  });

  it("displays error message when translation fails", async () => {
    const mockTranslate = vi.fn().mockRejectedValue(new Error("Network error"));

    render(
      <MeaningSelector
        meanings={mockMeanings}
        selectedMeanings={{}}
        word="destination"
        onTranslateDefinition={mockTranslate}
      />,
    );

    const translateButtons = screen.getAllByRole("button", {
      name: /dịch/i,
    });
    fireEvent.click(translateButtons[1]);

    await waitFor(() => {
      expect(
        screen.getByText("Dịch thất bại, vui lòng thử lại"),
      ).toBeInTheDocument();
    });
  });
});

