import { describe, it, expect } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import LanguageSwitcher from "../LanguageSwitcher";
import i18n from "../../../config/i18n";

describe("LanguageSwitcher component", () => {
  it("renders language switcher button and toggles language", async () => {
    await i18n.changeLanguage("vi");
    render(<LanguageSwitcher />);

    const button = screen.getByRole("button");
    expect(button).toBeInTheDocument();
    expect(screen.getAllByText(/VI|EN/)).toHaveLength(2);

    fireEvent.click(button);
    expect(i18n.resolvedLanguage).toBe("en");
    expect(screen.getAllByText(/VI|EN/)).toHaveLength(2);

    // Toggle back
    fireEvent.click(button);
    expect(i18n.resolvedLanguage).toBe("vi");
    expect(screen.getAllByText(/VI|EN/)).toHaveLength(2);
  });
});
