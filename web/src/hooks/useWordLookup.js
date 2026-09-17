import { useState, useEffect, useCallback } from "react";
import { useTranslation } from "react-i18next";
import { useAuthStore } from "../stores/auth.store";
import { useSettingsStore } from "../stores/settings.store";
import { useUIStore } from "../stores/ui.store";
import { lookupService } from "../services/lookup.service";
import { vocabularyService } from "../services/vocabulary.service";
import { useOnlineStatus } from "./useOnlineStatus";
import { useDebouncedSearch } from "./useDebouncedSearch";
import { useRateLimit } from "./useRateLimit";
import { validateWord } from "../utils/validators";

export function useWordLookup({ onLookupSuccess } = {}) {
  const { t } = useTranslation("addWord");
  const { user } = useAuthStore();
  const { settings } = useSettingsStore();
  const addToast = useUIStore((s) => s.addToast);
  const { isOnline } = useOnlineStatus();

  const [word, setWord] = useState("");
  const [lookupResult, setLookupResult] = useState(null);
  const [isLooking, setIsLooking] = useState(false);
  const [wordError, setWordError] = useState("");
  const [duplicateCount, setDuplicateCount] = useState(0);

  // Manual field overrides
  const [editFields, setEditFields] = useState({
    phonetic: "",
    cefr_level: "",
    usage_register: "",
  });

  // Rate limiting & double-click prevention
  const rateLimit = useRateLimit({
    maxRequests: 15,
    windowMs: 60000,
    cooldownMs: 2000,
  });

  const debouncedWord = useDebouncedSearch(word, 300);

  // Check for duplicates on debounced word change
  useEffect(() => {
    if (debouncedWord && user) {
      vocabularyService
        .checkDuplicate(user.id, debouncedWord)
        .then(({ count }) => setDuplicateCount(count));
    } else {
      setDuplicateCount(0);
    }
  }, [debouncedWord, user]);

  const speakWithBrowser = useCallback(
    (text) => {
      if (typeof window !== "undefined" && "speechSynthesis" in window && text) {
        try {
          window.speechSynthesis.cancel();
          const utterance = new SpeechSynthesisUtterance(text);
          utterance.lang = "en-US";
          window.speechSynthesis.speak(utterance);
          return;
        } catch {
          // Fall through to toast error
        }
      }
      addToast(t("toastAudioError"), "error");
    },
    [addToast, t],
  );

  const handlePlayAudio = useCallback(
    (url, wordText) => {
      if (url) {
        const audio = new Audio(url);
        audio.play().catch(() => speakWithBrowser(wordText || word));
        return;
      }
      speakWithBrowser(wordText || word);
    },
    [speakWithBrowser, word],
  );

  const handleLookup = async (customCallback) => {
    const validation = validateWord(word);
    if (!validation.valid) {
      setWordError(validation.error);
      return;
    }
    setWordError("");

    if (!isOnline) {
      addToast(t("toastNetworkRequired"), "error");
      return;
    }

    // Rate limiting & debounce double-click protection
    const check = rateLimit.canExecute();
    if (!check.allowed) {
      if (check.reason === "cooling_down") {
        addToast(t("rateLimit.toastTooFast"), "warning");
      } else if (
        check.reason === "rate_limited" ||
        check.reason === "extended_cooldown"
      ) {
        addToast(
          t("rateLimit.toastLimitReached", {
            max: rateLimit.maxRequests,
            seconds: check.waitSeconds || rateLimit.resetInSeconds,
          }),
          "warning",
        );
      }
      return;
    }

    rateLimit.recordRequest();
    setIsLooking(true);
    try {
      const provider = settings?.ai_provider || "gemini";
      const model = settings?.ai_model || undefined;
      const result = await lookupService.lookupWord(word, provider, model);
      setLookupResult(result);
      setEditFields({
        phonetic: result.phonetic || "",
        cefr_level: result.meanings?.[0]?.cefr_level || "",
        usage_register: result.meanings?.[0]?.usage_register || "",
      });

      if (customCallback) {
        customCallback(result);
      } else if (onLookupSuccess) {
        onLookupSuccess(result);
      }
    } catch (err) {
      const errorMsg = err?.message || "";
      const isServerRateLimit =
        err?.status === 429 ||
        /429|rate limit|quota|resource_exhausted/i.test(errorMsg);

      if (isServerRateLimit) {
        rateLimit.triggerCooldown(30);
        addToast(
          t("rateLimit.toastServerExhausted", { seconds: 30 }),
          "error",
        );
      } else {
        addToast(err.message || t("toastLookupError"), "error");
      }
    } finally {
      setIsLooking(false);
    }
  };

  return {
    word,
    setWord,
    wordError,
    setWordError,
    lookupResult,
    setLookupResult,
    isLooking,
    editFields,
    setEditFields,
    rateLimit,
    duplicateCount,
    handleLookup,
    handlePlayAudio,
  };
}
