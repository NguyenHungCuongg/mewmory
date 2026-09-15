import { describe, it, expect, vi, beforeEach, afterEach } from "vitest";
import { render, screen, fireEvent } from "@testing-library/react";
import ErrorBoundary from "../ErrorBoundary";

// Component that throws error on demand
function BuggyComponent({ shouldThrow }) {
  if (shouldThrow) {
    throw new Error("Simulated component explosion!");
  }
  return <div>Normal Component Content</div>;
}

describe("ErrorBoundary", () => {
  let consoleErrorSpy;

  beforeEach(() => {
    // Suppress console.error during expected throw tests
    consoleErrorSpy = vi.spyOn(console, "error").mockImplementation(() => {});
  });

  afterEach(() => {
    consoleErrorSpy.mockRestore();
  });

  it("renders children when there is no error", () => {
    render(
      <ErrorBoundary>
        <BuggyComponent shouldThrow={false} />
      </ErrorBoundary>,
    );

    expect(screen.getByText("Normal Component Content")).toBeInTheDocument();
  });

  it("catches render error and displays default ErrorFallbackPage", () => {
    render(
      <ErrorBoundary>
        <BuggyComponent shouldThrow={true} />
      </ErrorBoundary>,
    );

    // Fallback UI should be displayed
    expect(screen.getByRole("alert")).toBeInTheDocument();
    expect(
      screen.getByText(/Đã xảy ra sự cố ngoài ý muốn|Something went wrong/i),
    ).toBeInTheDocument();
    expect(screen.getByText(/Thử lại|Try again/i)).toBeInTheDocument();
    expect(screen.getByText(/Tải lại trang|Reload page/i)).toBeInTheDocument();
  });

  it("calls onError callback when an error is caught", () => {
    const onErrorMock = vi.fn();

    render(
      <ErrorBoundary onError={onErrorMock}>
        <BuggyComponent shouldThrow={true} />
      </ErrorBoundary>,
    );

    expect(onErrorMock).toHaveBeenCalledTimes(1);
    expect(onErrorMock).toHaveBeenCalledWith(
      expect.any(Error),
      expect.objectContaining({
        componentStack: expect.any(String),
      }),
    );
  });

  it("resets error state when reset button is clicked", () => {
    const onResetMock = vi.fn();

    const { rerender } = render(
      <ErrorBoundary onReset={onResetMock}>
        <BuggyComponent shouldThrow={true} />
      </ErrorBoundary>,
    );

    expect(screen.getByRole("alert")).toBeInTheDocument();

    // Fix the condition so rerendering doesn't immediately throw again
    rerender(
      <ErrorBoundary onReset={onResetMock}>
        <BuggyComponent shouldThrow={false} />
      </ErrorBoundary>,
    );

    // Click "Thử lại" (Try again)
    const tryAgainBtn = screen.getByText(/Thử lại|Try again/i);
    fireEvent.click(tryAgainBtn);

    expect(onResetMock).toHaveBeenCalledTimes(1);
    expect(screen.getByText("Normal Component Content")).toBeInTheDocument();
  });

  it("supports custom fallback element", () => {
    render(
      <ErrorBoundary fallback={<div>Custom Fallback View</div>}>
        <BuggyComponent shouldThrow={true} />
      </ErrorBoundary>,
    );

    expect(screen.getByText("Custom Fallback View")).toBeInTheDocument();
    expect(screen.queryByRole("alert")).not.toBeInTheDocument();
  });

  it("supports custom fallback render function", () => {
    const customFallback = vi.fn(({ error, resetErrorBoundary }) => (
      <div>
        <p>Error: {error.message}</p>
        <button onClick={resetErrorBoundary}>Recover</button>
      </div>
    ));

    render(
      <ErrorBoundary fallback={customFallback}>
        <BuggyComponent shouldThrow={true} />
      </ErrorBoundary>,
    );

    expect(
      screen.getByText("Error: Simulated component explosion!"),
    ).toBeInTheDocument();
    expect(screen.getByText("Recover")).toBeInTheDocument();
    expect(customFallback).toHaveBeenCalledWith(
      expect.objectContaining({
        error: expect.any(Error),
        resetErrorBoundary: expect.any(Function),
      }),
    );
  });
});
