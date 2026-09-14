import { describe, it, expect, vi } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import LookupResult from "../LookupResult";

describe("LookupResult", () => {
  it("renders word and phonetic correctly", () => {
    const mockResult = {
      word: "resilient",
      phonetic: "/rɪˈzɪl.jənt/",
      audio_url: "https://example.com/resilient.mp3",
      source: { dictionary: true, ai: true },
    };

    render(<LookupResult result={mockResult} onPlayAudio={vi.fn()} />);

    expect(screen.getByText("resilient")).toBeInTheDocument();
    expect(screen.getByText("/rɪˈzɪl.jənt/")).toBeInTheDocument();
    expect(screen.getByText("Dictionary")).toBeInTheDocument();
    expect(screen.getByText("AI")).toBeInTheDocument();
  });

  it("renders audio pronunciation button even when audio_url is null (for Web Speech fallback)", () => {
    const onPlayAudioMock = vi.fn();
    const mockResult = {
      word: "serendipity",
      phonetic: "/ˌser.ənˈdɪp.ə.ti/",
      audio_url: null,
      source: { dictionary: false, ai: true },
    };

    render(
      <LookupResult result={mockResult} onPlayAudio={onPlayAudioMock} />,
    );

    const pronounceBtn = screen.getByRole("button", { name: /phát âm|pronounce/i });
    expect(pronounceBtn).toBeInTheDocument();

    fireEvent.click(pronounceBtn);
    expect(onPlayAudioMock).toHaveBeenCalledWith(null, "serendipity");
  });

  it("renders phonetic provided by AI fallback", () => {
    const mockResult = {
      word: "ephemeral",
      phonetic: "/ɪˈfem.ər.əl/",
      audio_url: null,
      source: { dictionary: false, ai: true },
    };

    render(<LookupResult result={mockResult} onPlayAudio={vi.fn()} />);

    expect(screen.getByText("/ɪˈfem.ər.əl/")).toBeInTheDocument();
  });
});
