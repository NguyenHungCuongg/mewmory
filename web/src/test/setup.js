import "@testing-library/jest-dom";
import i18n from "../config/i18n";

// Ensure tests run in Vietnamese by default to match existing test assertions
i18n.changeLanguage("vi");
