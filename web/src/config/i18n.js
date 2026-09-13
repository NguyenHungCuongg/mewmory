import i18n from "i18next";
import { initReactI18next } from "react-i18next";
import LanguageDetector from "i18next-browser-languagedetector";

import viCommon from "../locales/vi/common.json";
import viHeader from "../locales/vi/header.json";
import viSidebar from "../locales/vi/sidebar.json";
import viDashboard from "../locales/vi/dashboard.json";
import viVocabulary from "../locales/vi/vocabulary.json";
import viCollection from "../locales/vi/collection.json";
import viAuth from "../locales/vi/auth.json";
import viSettings from "../locales/vi/settings.json";
import viWordForm from "../locales/vi/wordForm.json";
import viAddWord from "../locales/vi/addWord.json";

import enCommon from "../locales/en/common.json";
import enHeader from "../locales/en/header.json";
import enSidebar from "../locales/en/sidebar.json";
import enDashboard from "../locales/en/dashboard.json";
import enVocabulary from "../locales/en/vocabulary.json";
import enCollection from "../locales/en/collection.json";
import enAuth from "../locales/en/auth.json";
import enSettings from "../locales/en/settings.json";
import enWordForm from "../locales/en/wordForm.json";
import enAddWord from "../locales/en/addWord.json";

export const defaultNS = "common";
export const resources = {
  vi: {
    common: viCommon,
    header: viHeader,
    sidebar: viSidebar,
    dashboard: viDashboard,
    vocabulary: viVocabulary,
    collection: viCollection,
    auth: viAuth,
    settings: viSettings,
    wordForm: viWordForm,
    addWord: viAddWord,
  },
  en: {
    common: enCommon,
    header: enHeader,
    sidebar: enSidebar,
    dashboard: enDashboard,
    vocabulary: enVocabulary,
    collection: enCollection,
    auth: enAuth,
    settings: enSettings,
    wordForm: enWordForm,
    addWord: enAddWord,
  },
};

i18n
  .use(LanguageDetector)
  .use(initReactI18next)
  .init({
    resources,
    defaultNS,
    fallbackLng: "vi",
    interpolation: {
      escapeValue: false,
    },
    detection: {
      order: ["localStorage", "navigator"],
      caches: ["localStorage"],
    },
  });

export default i18n;
