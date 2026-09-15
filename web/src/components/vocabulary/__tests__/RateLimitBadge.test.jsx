import { describe, it, expect } from "vitest";
import { render, screen } from "@testing-library/react";
import RateLimitBadge from "../RateLimitBadge";

describe("RateLimitBadge", () => {
  it("renders normal quota badge when quota is plentiful", () => {
    render(
      <RateLimitBadge
        remainingRequests={15}
        maxRequests={15}
        isRateLimited={false}
        isCoolingDown={false}
        resetInSeconds={0}
      />,
    );

    expect(screen.getByTestId("rate-limit-normal")).toBeInTheDocument();
    expect(screen.getByText(/15\/15/)).toBeInTheDocument();
  });

  it("renders warning quota badge when 3 or fewer requests remain", () => {
    render(
      <RateLimitBadge
        remainingRequests={2}
        maxRequests={15}
        isRateLimited={false}
        isCoolingDown={false}
        resetInSeconds={35}
      />,
    );

    expect(screen.getByTestId("rate-limit-normal")).toBeInTheDocument();
    expect(screen.getByText(/2\/15/)).toBeInTheDocument();
    expect(screen.getByText("(35s)")).toBeInTheDocument();
  });

  it("renders cooling badge during debounce period", () => {
    render(
      <RateLimitBadge
        remainingRequests={14}
        maxRequests={15}
        isRateLimited={false}
        isCoolingDown={true}
        resetInSeconds={0}
      />,
    );

    expect(screen.getByTestId("rate-limit-cooling")).toBeInTheDocument();
  });

  it("renders exhausted badge when rate limited", () => {
    render(
      <RateLimitBadge
        remainingRequests={0}
        maxRequests={15}
        isRateLimited={true}
        isCoolingDown={false}
        resetInSeconds={42}
      />,
    );

    expect(screen.getByTestId("rate-limit-exhausted")).toBeInTheDocument();
    expect(screen.getByText(/42s/)).toBeInTheDocument();
  });
});
