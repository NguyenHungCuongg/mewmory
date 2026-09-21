import { render, screen, fireEvent } from "@testing-library/react";
import { describe, it, expect } from "vitest";
import UserAvatar from "../UserAvatar";

describe("UserAvatar Component", () => {
  it("renders uppercase initial letter from name", () => {
    render(<UserAvatar name="Cường" email="cuong@example.com" />);
    expect(screen.getByText("C")).toBeInTheDocument();
  });

  it("renders uppercase initial from email when name is missing", () => {
    render(<UserAvatar email="alex@example.com" />);
    expect(screen.getByText("A")).toBeInTheDocument();
  });

  it("renders ? when both name and email are empty", () => {
    render(<UserAvatar />);
    expect(screen.getByText("?")).toBeInTheDocument();
  });

  it("deterministically uses the same background color for the same identifier", () => {
    const { container: first } = render(<UserAvatar name="Cường" />);
    const { container: second } = render(<UserAvatar name="Cường" />);
    const firstBg = first.querySelector("div").style.backgroundColor;
    const secondBg = second.querySelector("div").style.backgroundColor;
    expect(firstBg).toBe(secondBg);
  });

  it("renders image if avatarUrl is provided", () => {
    render(
      <UserAvatar
        name="Cường"
        avatarUrl="https://example.com/avatar.jpg"
      />
    );
    const img = screen.getByRole("img", { name: "Cường" });
    expect(img).toBeInTheDocument();
    expect(img).toHaveAttribute("src", "https://example.com/avatar.jpg");
  });

  it("falls back to initial letter if image loading fails", () => {
    render(
      <UserAvatar
        name="Cường"
        avatarUrl="https://example.com/broken.jpg"
      />
    );
    const img = screen.getByRole("img");
    fireEvent.error(img);
    expect(screen.getByText("C")).toBeInTheDocument();
  });
});
