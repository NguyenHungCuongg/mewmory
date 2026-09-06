import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import { BrowserRouter } from "react-router-dom";
import AddWordPage from "../AddWordPage";
import { useAuthStore } from "../../stores/auth.store";
import { useCollectionStore } from "../../stores/collection.store";
import { useUIStore } from "../../stores/ui.store";
import { vocabularyService } from "../../services/vocabulary.service";
import { lookupService } from "../../services/lookup.service";

const mockNavigate = vi.fn();
vi.mock("react-router-dom", async () => {
  const actual = await vi.importActual("react-router-dom");
  return {
    ...actual,
    useNavigate: () => mockNavigate,
    useSearchParams: () => [new URLSearchParams()],
  };
});

vi.mock("../../services/vocabulary.service", () => ({
  vocabularyService: {
    checkDuplicate: vi.fn().mockResolvedValue({ count: 0 }),
    create: vi.fn().mockResolvedValue({ id: "new-vocab-1" }),
  },
}));

vi.mock("../../services/lookup.service", () => ({
  lookupService: {
    lookupWord: vi.fn(),
    translateDefinition: vi.fn(),
  },
}));

describe("AddWordPage", () => {
  let colCounter = 0;
  const mockAddCollection = vi.fn().mockImplementation(async (data) => {
    colCounter += 1;
    const newCol = {
      id: `new-col-${colCounter}`,
      name: data.name,
      word_count: 0,
      is_ai_generated: data.is_ai_generated || false,
    };
    useCollectionStore.setState((s) => ({ items: [...s.items, newCol] }));
    return newCol;
  });

  beforeEach(() => {
    vi.clearAllMocks();
    useAuthStore.setState({ user: { id: "user-123" } });
    useCollectionStore.setState({
      items: [{ id: "col-1", name: "Daily English" }],
      fetchCollections: vi.fn(),
      addCollection: mockAddCollection,
    });
    useUIStore.setState({ toasts: [] });
  });

  const renderComponent = () =>
    render(
      <BrowserRouter>
        <AddWordPage />
      </BrowserRouter>,
    );

  it("renders mode switcher with auto mode active by default", () => {
    renderComponent();
    expect(screen.getByText("Tra cứu tự động (AI & Từ điển)")).toBeInTheDocument();
    expect(screen.getByText("Tự nhập thủ công")).toBeInTheDocument();
    expect(screen.getByPlaceholderText("Nhập từ tiếng Anh...")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Lookup" })).toBeInTheDocument();
  });

  it("switches to manual mode and displays WordForm", () => {
    renderComponent();
    const manualTabBtn = screen.getByText("Tự nhập thủ công");
    fireEvent.click(manualTabBtn);

    // Form inputs should now be visible
    expect(screen.getByLabelText("Từ (Word)")).toBeInTheDocument();
    expect(screen.getByLabelText("Phiên âm (IPA)")).toBeInTheDocument();
    expect(screen.getByLabelText("Nghĩa tiếng Việt")).toBeInTheDocument();
    expect(screen.getByRole("button", { name: "Tạo từ vựng" })).toBeInTheDocument();
  });

  it("preserves typed word when switching from auto to manual mode", () => {
    renderComponent();

    // Type in auto mode lookup input
    fireEvent.change(screen.getByPlaceholderText("Nhập từ tiếng Anh..."), {
      target: { value: "ubiquitous" },
    });

    // Switch to manual mode
    fireEvent.click(screen.getByText("Tự nhập thủ công"));

    // Should prefill the word input in manual form
    expect(screen.getByLabelText("Từ (Word)")).toHaveValue("ubiquitous");
  });

  it("submits manual form and creates vocabulary", async () => {
    renderComponent();

    // Switch to manual mode
    fireEvent.click(screen.getByText("Tự nhập thủ công"));

    fireEvent.change(screen.getByLabelText("Từ (Word)"), {
      target: { value: "pragmatic" },
    });
    fireEvent.change(screen.getByLabelText("Nghĩa tiếng Việt"), {
      target: { value: "thực tế, thực dụng" },
    });

    fireEvent.click(screen.getByRole("button", { name: "Tạo từ vựng" }));

    await waitFor(() => {
      expect(vocabularyService.create).toHaveBeenCalledWith(
        expect.objectContaining({
          user_id: "user-123",
          word: "pragmatic",
        }),
        [expect.objectContaining({ definition_vi: "thực tế, thực dụng" })],
        [],
      );
    });

    await waitFor(() => {
      expect(mockNavigate).toHaveBeenCalledWith("/vocabulary");
      const toasts = useUIStore.getState().toasts;
      expect(toasts.length).toBe(1);
      expect(toasts[0].message).toBe("Thêm từ vựng thành công!");
    });
  });

  it("looks up word, allows inline editing of Vietnamese definition, and saves updated meaning", async () => {
    lookupService.lookupWord.mockResolvedValueOnce({
      word: "destination",
      phonetic: "/ˌdestɪˈneɪʃn/",
      audio_url: "https://example.com/audio.mp3",
      meanings: [
        {
          part_of_speech: "noun",
          cefr_level: "B1",
          usage_register: "neutral",
          definitions: [
            {
              definition_en: "A place to which one is journeying.",
              definition_vi: "Nơi đến ban đầu",
              example: "We reached our destination.",
            },
          ],
        },
      ],
      suggested_collections: ["Daily English", "Travel"],
    });

    renderComponent();

    fireEvent.change(screen.getByPlaceholderText("Nhập từ tiếng Anh..."), {
      target: { value: "destination" },
    });
    fireEvent.click(screen.getByRole("button", { name: "Lookup" }));

    await waitFor(() => {
      expect(screen.getByText("destination")).toBeInTheDocument();
      expect(screen.getByDisplayValue("Nơi đến ban đầu")).toBeInTheDocument();
    });

    // Inline edit Vietnamese definition
    const viInput = screen.getByDisplayValue("Nơi đến ban đầu");
    fireEvent.change(viInput, {
      target: { value: "Điểm đến du lịch lý tưởng" },
    });

    // Click Save
    const saveButton = screen.getByRole("button", { name: /Lưu \(1 nghĩa\)/ });
    fireEvent.click(saveButton);

    await waitFor(() => {
      expect(vocabularyService.create).toHaveBeenCalledWith(
        expect.objectContaining({
          user_id: "user-123",
          word: "destination",
          part_of_speech: "noun",
        }),
        [
          expect.objectContaining({
            definition_en: "A place to which one is journeying.",
            definition_vi: "Điểm đến du lịch lý tưởng",
          }),
        ],
        expect.any(Array),
      );
    });
  });

  it("displays AI suggestion badge on existing collections and supports inline quick create", async () => {
    lookupService.lookupWord.mockResolvedValueOnce({
      word: "destination",
      meanings: [
        {
          part_of_speech: "noun",
          definitions: [{ definition_en: "A place", definition_vi: "Nơi đến" }],
        },
      ],
      suggested_collections: ["Daily English", "Travel"],
    });

    renderComponent();

    fireEvent.change(screen.getByPlaceholderText("Nhập từ tiếng Anh..."), {
      target: { value: "destination" },
    });
    fireEvent.click(screen.getByRole("button", { name: "Lookup" }));

    await waitFor(() => {
      // "Daily English" is in store and in AI suggestions -> should have "✨ Gợi ý"
      expect(screen.getByText("✨ Gợi ý")).toBeInTheDocument();
      // "Travel" is suggested by AI but not yet in store -> should appear in unmatched suggestions
      expect(screen.getByText("+ ✨ Travel")).toBeInTheDocument();
    });

    // Test 1-click creation from AI suggestion "+ ✨ Travel"
    const travelBtn = screen.getByText("+ ✨ Travel");
    fireEvent.click(travelBtn);

    await waitFor(() => {
      expect(mockAddCollection).toHaveBeenCalledWith({
        user_id: "user-123",
        name: "Travel",
        is_ai_generated: true,
      });
    });

    // Test quick add custom collection via "+ Tạo mới"
    const createBtn = screen.getByText("+ Tạo mới");
    fireEvent.click(createBtn);

    const input = screen.getByPlaceholderText("Tên bộ sưu tập mới...");
    fireEvent.change(input, { target: { value: "IELTS Speaking" } });
    fireEvent.click(screen.getByRole("button", { name: "Tạo" }));

    await waitFor(() => {
      expect(mockAddCollection).toHaveBeenCalledWith({
        user_id: "user-123",
        name: "IELTS Speaking",
      });
    });
  });

  it("translates definition on demand and saves it", async () => {
    lookupService.lookupWord.mockResolvedValueOnce({
      word: "supermarket",
      phonetic: "/ˈsuːpəmɑːkɪt/",
      meanings: [
        {
          part_of_speech: "noun",
          definitions: [
            {
              definition_en:
                "A large self-service shop selling food and household goods.",
              definition_vi: null,
            },
          ],
        },
      ],
    });

    lookupService.translateDefinition.mockResolvedValueOnce(
      "Siêu thị (cửa hàng tự phục vụ lớn)",
    );

    renderComponent();

    fireEvent.change(screen.getByPlaceholderText("Nhập từ tiếng Anh..."), {
      target: { value: "supermarket" },
    });
    fireEvent.click(screen.getByRole("button", { name: "Lookup" }));

    await waitFor(() => {
      expect(
        screen.getByText(
          "A large self-service shop selling food and household goods.",
        ),
      ).toBeInTheDocument();
    });

    // Click "Dịch" button
    const translateBtn = screen.getByRole("button", { name: /dịch/i });
    fireEvent.click(translateBtn);

    await waitFor(() => {
      expect(lookupService.translateDefinition).toHaveBeenCalledWith({
        text: "A large self-service shop selling food and household goods.",
        partOfSpeech: "noun",
        word: "supermarket",
      });
      expect(
        screen.getByDisplayValue("Siêu thị (cửa hàng tự phục vụ lớn)"),
      ).toBeInTheDocument();
    });

    // Now save
    fireEvent.click(screen.getByRole("button", { name: /Lưu \(1 nghĩa\)/ }));

    await waitFor(() => {
      expect(vocabularyService.create).toHaveBeenCalledWith(
        expect.objectContaining({ word: "supermarket" }),
        [
          expect.objectContaining({
            definition_vi: "Siêu thị (cửa hàng tự phục vụ lớn)",
          }),
        ],
        [],
      );
    });
  });
});
