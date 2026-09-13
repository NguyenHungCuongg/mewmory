import { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { useAuthStore } from "../stores/auth.store";
import { useVocabularyStore } from "../stores/vocabulary.store";
import { useCollectionStore } from "../stores/collection.store";
import { useDebouncedSearch } from "../hooks/useDebouncedSearch";
import Header from "../components/layout/Header";
import Button from "../components/common/Button";
import Input from "../components/common/Input";
import LoadingSpinner from "../components/common/LoadingSpinner";
import WordCard from "../components/vocabulary/WordCard";
import FilterBar from "../components/vocabulary/FilterBar";
import EmptyState from "../components/common/EmptyState";
import { IconSearch } from "../components/common/Icons";

const PAGE_SIZE = 12;

export default function VocabularyPage() {
  const { t } = useTranslation("vocabulary");
  const { user } = useAuthStore();
  const {
    items,
    total,
    isLoading,
    search,
    filters,
    sort,
    offset,
    setSearch,
    setFilters,
    setSort,
    setOffset,
    fetchVocabularies,
  } = useVocabularyStore();

  const { items: collections, fetchCollections } = useCollectionStore();

  const [searchInput, setSearchInput] = useState(search);
  const debouncedSearch = useDebouncedSearch(searchInput, 300);

  // Sync debounced search to store
  useEffect(() => {
    setSearch(debouncedSearch);
  }, [debouncedSearch, setSearch]);

  // Load collections
  useEffect(() => {
    if (user) {
      fetchCollections(user.id);
    }
  }, [user, fetchCollections]);

  // Refetch vocabularies when filters/search/sort/offset change
  useEffect(() => {
    if (user) {
      fetchVocabularies(user.id);
    }
  }, [user, search, filters, sort, offset, fetchVocabularies]);

  const handleSortChange = (e) => {
    const value = e.target.value;
    if (value === "newest") setSort({ field: "created_at", order: "desc" });
    else if (value === "oldest") setSort({ field: "created_at", order: "asc" });
    else if (value === "az") setSort({ field: "word", order: "asc" });
    else if (value === "za") setSort({ field: "word", order: "desc" });
  };

  const currentSortValue =
    sort.field === "word"
      ? sort.order === "asc"
        ? "az"
        : "za"
      : sort.order === "asc"
        ? "oldest"
        : "newest";

  const totalPages = Math.ceil(total / PAGE_SIZE) || 1;
  const currentPage = Math.floor(offset / PAGE_SIZE) + 1;

  const handlePrevPage = () => {
    if (offset > 0) setOffset(Math.max(0, offset - PAGE_SIZE));
  };

  const handleNextPage = () => {
    if (offset + PAGE_SIZE < total) setOffset(offset + PAGE_SIZE);
  };

  return (
    <>
      <Header
        title={t("title")}
        actions={
          <Link to="/vocabulary/add">
            <Button>{t("addNewWord")}</Button>
          </Link>
        }
      />

      <div className="p-6 max-w-6xl mx-auto flex flex-col gap-6">
        {/* Top Controls: Search & Sort */}
        <div className="flex flex-col sm:flex-row gap-4 items-stretch sm:items-center justify-between">
          <div className="w-full sm:max-w-md">
            <Input
              id="search-vocab"
              placeholder={t("searchPlaceholder")}
              value={searchInput}
              onChange={(e) => setSearchInput(e.target.value)}
            />
          </div>

          <div className="flex items-center gap-3 self-end sm:self-auto">
            <span className="text-body-sm text-smoke whitespace-nowrap">
              {t("sort.label")}
            </span>
            <select
              value={currentSortValue}
              onChange={handleSortChange}
              className="px-3 py-2 rounded-pill border border-stone bg-eggshell text-body-sm text-graphite focus:outline-none focus:border-ink cursor-pointer"
            >
              <option value="newest">{t("sort.newest")}</option>
              <option value="oldest">{t("sort.oldest")}</option>
              <option value="az">{t("sort.az")}</option>
              <option value="za">{t("sort.za")}</option>
            </select>
          </div>
        </div>

        {/* Filter Bar */}
        <FilterBar
          filters={filters}
          onFilterChange={setFilters}
          collections={collections}
        />

        {/* Results Info */}
        <div className="flex items-center justify-between text-body-sm text-smoke">
          <span>
            {t("resultsInfo", { count: items.length, total })}
          </span>
        </div>

        {/* Vocabulary Grid / States */}
        {isLoading && items.length === 0 ? (
          <div className="flex items-center justify-center py-20">
            <LoadingSpinner size="lg" />
          </div>
        ) : items.length === 0 ? (
          <EmptyState
            icon={<IconSearch className="w-7 h-7 text-smoke" />}
            title={t("empty.title")}
            description={
              searchInput || Object.keys(filters).length > 0
                ? t("empty.filtered")
                : t("empty.noWords")
            }
            action={
              !searchInput && Object.keys(filters).length === 0 ? (
                <Link to="/vocabulary/add">
                  <Button>{t("addNewWordNow")}</Button>
                </Link>
              ) : null
            }
          />
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 animate-fade-in">
            {items.map((vocab) => (
              <WordCard key={vocab.id} vocabulary={vocab} />
            ))}
          </div>
        )}

        {/* Pagination */}
        {total > PAGE_SIZE && (
          <div className="flex items-center justify-center gap-4 mt-6 pt-6 border-t border-stone">
            <Button
              variant="secondary"
              size="sm"
              onClick={handlePrevPage}
              disabled={offset === 0 || isLoading}
            >
              {t("pagination.prev")}
            </Button>
            <span className="text-body-sm text-smoke">
              {t("pagination.pageInfo", { current: currentPage, total: totalPages })}
            </span>
            <Button
              variant="secondary"
              size="sm"
              onClick={handleNextPage}
              disabled={offset + PAGE_SIZE >= total || isLoading}
            >
              {t("pagination.next")}
            </Button>
          </div>
        )}
      </div>
    </>
  );
}

