import React, { Component } from "react";
import ErrorFallbackPage from "./ErrorFallbackPage";

export default class ErrorBoundary extends Component {
  constructor(props) {
    super(props);
    this.state = {
      hasError: false,
      error: null,
      errorInfo: null,
    };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true, error };
  }

  componentDidCatch(error, errorInfo) {
    this.setState({ errorInfo });

    // Call optional custom onError callback (e.g. Sentry / logging service)
    if (typeof this.props.onError === "function") {
      try {
        this.props.onError(error, errorInfo);
      } catch (loggingError) {
        console.error("Failed to execute onError callback:", loggingError);
      }
    }

    if (process.env.NODE_ENV !== "test") {
      console.error("ErrorBoundary caught an uncaught error:", error, errorInfo);
    }
  }

  resetErrorBoundary = () => {
    this.setState({
      hasError: false,
      error: null,
      errorInfo: null,
    });

    if (typeof this.props.onReset === "function") {
      this.props.onReset();
    }
  };

  render() {
    if (this.state.hasError) {
      const { fallback } = this.props;

      if (typeof fallback === "function") {
        return fallback({
          error: this.state.error,
          errorInfo: this.state.errorInfo,
          resetErrorBoundary: this.resetErrorBoundary,
        });
      }

      if (React.isValidElement(fallback)) {
        return fallback;
      }

      return (
        <ErrorFallbackPage
          error={this.state.error}
          errorInfo={this.state.errorInfo}
          resetErrorBoundary={this.resetErrorBoundary}
        />
      );
    }

    return this.props.children;
  }
}
