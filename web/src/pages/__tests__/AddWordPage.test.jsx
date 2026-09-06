import { describe, it, expect, vi, beforeEach } from "vitest";
import { render, screen, fireEvent, waitFor } from "@testing-library/react";
import { BrowserRouter } from "react-router-dom";
import AddWordPage from "../AddWordPage";
import { useAuthStore } from "../../stores/auth.store";
import { useCollectionStore } from "../../stores/collection.store";
import { useUIStore } from "../../stores/ui.store";
import { vocabularyService } from "../../services/vocabulary.service";

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
  },
}));

describe("AddWordPage", () => {
  beforeEach(() => {
    vi.clearAllMocks();
    useAuthStore.setState({ user: { id: "user-123" } });
    useCollectionStore.setState({
      items: [{ id: "col-1", name: "Daily English" }],
      fetchCollections: vi.fn(),
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
});
