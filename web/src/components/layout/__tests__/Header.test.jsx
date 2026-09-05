import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import Header from "../Header";

describe("Header component", () => {
  it("renders title correctly", () => {
    render(<Header title="Từ vựng của tôi" />);
    expect(screen.getByText("Từ vựng của tôi")).toBeInTheDocument();
  });

  it("renders actions when passed", () => {
    render(
      <Header
        title="Từ vựng của tôi"
        actions={<button data-testid="add-btn">+ Thêm từ mới</button>}
      />,
    );
    expect(screen.getByTestId("add-btn")).toBeInTheDocument();
    expect(screen.getByText("+ Thêm từ mới")).toBeInTheDocument();
  });
});
