import { describe, it, expect, vi } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import WordForm from "../WordForm";

describe("WordForm component", () => {
  it("renders with empty initialData without crashing", () => {
    render(<WordForm onSubmit={vi.fn()} onCancel={vi.fn()} submitLabel="Tạo từ vựng" />);
    expect(screen.getByLabelText("Từ (Word)")).toHaveValue("");
    expect(screen.getByRole("button", { name: "Tạo từ vựng" })).toBeInTheDocument();
  });

  it("renders with prefilled initialData", () => {
    const initialData = {
      vocabulary: {
        word: "serendipity",
        phonetic: "/ˌser.ənˈdɪp.ə.ti/",
        part_of_speech: "noun",
        cefr_level: "C1",
        usage_register: "formal",
      },
      definitions: [
        {
          definition_vi: "Sự tình cờ may mắn",
          definition_en: "Finding good things without looking for them",
          example: "It was pure serendipity that we met.",
        },
      ],
    };

    render(
      <WordForm
        initialData={initialData}
        onSubmit={vi.fn()}
        onCancel={vi.fn()}
      />,
    );

    expect(screen.getByLabelText("Từ (Word)")).toHaveValue("serendipity");
    expect(screen.getByLabelText("Phiên âm (IPA)")).toHaveValue("/ˌser.ənˈdɪp.ə.ti/");
    expect(screen.getByLabelText("Nghĩa tiếng Việt")).toHaveValue("Sự tình cờ may mắn");
  });

  it("shows error when word is empty on submit", () => {
    const onSubmit = vi.fn();
    render(<WordForm onSubmit={onSubmit} onCancel={vi.fn()} />);

    fireEvent.click(screen.getByRole("button", { name: "Lưu thay đổi" }));
    expect(screen.getByText("Từ vựng không được để trống")).toBeInTheDocument();
    expect(onSubmit).not.toHaveBeenCalled();
  });

  it("shows error when all definitions are empty on submit", () => {
    const onSubmit = vi.fn();
    render(<WordForm onSubmit={onSubmit} onCancel={vi.fn()} />);

    fireEvent.change(screen.getByLabelText("Từ (Word)"), {
      target: { value: "resilient" },
    });

    fireEvent.click(screen.getByRole("button", { name: "Lưu thay đổi" }));
    expect(
      screen.getByText("Cần có ít nhất một định nghĩa tiếng Anh hoặc tiếng Việt"),
    ).toBeInTheDocument();
    expect(onSubmit).not.toHaveBeenCalled();
  });

  it("submits properly formatted data when valid", () => {
    const onSubmit = vi.fn();
    const collections = [{ id: "col-1", name: "IELTS" }];

    render(
      <WordForm
        collections={collections}
        onSubmit={onSubmit}
        onCancel={vi.fn()}
        submitLabel="Tạo từ vựng"
      />,
    );

    fireEvent.change(screen.getByLabelText("Từ (Word)"), {
      target: { value: "ephemeral" },
    });
    fireEvent.change(screen.getByLabelText("Nghĩa tiếng Việt"), {
      target: { value: "phù du, chóng tàn" },
    });

    // Select collection
    fireEvent.click(screen.getByText("+ IELTS"));

    fireEvent.click(screen.getByRole("button", { name: "Tạo từ vựng" }));

    expect(onSubmit).toHaveBeenCalledWith({
      vocabulary: expect.objectContaining({
        word: "ephemeral",
      }),
      definitions: [
        expect.objectContaining({
          definition_vi: "phù du, chóng tàn",
        }),
      ],
      collectionIds: ["col-1"],
    });
  });
});
