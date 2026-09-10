import { useState, useEffect, useCallback } from "react";
import { Link } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { useAuthStore } from "../stores/auth.store";
import { statisticsService } from "../services/statistics.service";
import { collectionService } from "../services/collection.service";
import Header from "../components/layout/Header";
import Button from "../components/common/Button";
import LoadingSpinner from "../components/common/LoadingSpinner";
import DailyReviewWidget from "../components/dashboard/DailyReviewWidget";
import StatsOverview from "../components/dashboard/StatsOverview";
import StreakChart from "../components/dashboard/StreakChart";
import LevelDistribution from "../components/dashboard/LevelDistribution";
import CollectionDistribution from "../components/dashboard/CollectionDistribution";

export default function DashboardPage() {
  const { t } = useTranslation("dashboard");
  const { user } = useAuthStore();

  const [isLoading, setIsLoading] = useState(true);
  const [totalVocab, setTotalVocab] = useState(0);
  const [totalCollections, setTotalCollections] = useState(0);
  const [newThisWeek, setNewThisWeek] = useState(0);
  const [dailyStats, setDailyStats] = useState([]);
  const [levelStats, setLevelStats] = useState([]);
  const [collectionStats, setCollectionStats] = useState([]);
  const [randomWord, setRandomWord] = useState(null);
  const [isRandomLoading, setIsRandomLoading] = useState(false);

  const loadRandomWord = useCallback(async () => {
    if (!user) return;
    setIsRandomLoading(true);
    try {
      const word = await statisticsService.getRandomWord(user.id);
      setRandomWord(word);
    } catch (err) {
      console.error("Error loading random word:", err);
    } finally {
      setIsRandomLoading(false);
    }
  }, [user]);

  const loadDashboardData = useCallback(async () => {
    if (!user) return;
    setIsLoading(true);
    try {
      const [
        count,
        collectionsData,
        daily,
        levels,
        colDist,
      ] = await Promise.all([
        statisticsService.getTotalCount(user.id),
        collectionService.getAll(user.id),
        statisticsService.getDailyWordCount(user.id, 14),
        statisticsService.getLevelDistribution(user.id),
        statisticsService.getCollectionDistribution(user.id),
      ]);

      setTotalVocab(count);
      setTotalCollections(collectionsData.items.length);
      setDailyStats(daily);
      setLevelStats(levels);
      setCollectionStats(colDist);

      // Compute words added in last 14 days
      const totalRecent = daily.reduce((acc, curr) => acc + curr.count, 0);
      setNewThisWeek(totalRecent);

      await loadRandomWord();
    } catch (err) {
      console.error("Error loading dashboard data:", err);
    } finally {
      setIsLoading(false);
    }
  }, [user, loadRandomWord]);

  useEffect(() => {
    loadDashboardData();
  }, [loadDashboardData]);

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

      <div className="p-6 max-w-6xl mx-auto flex flex-col gap-8">
        {/* Daily Review Widget */}
        <DailyReviewWidget
          randomWord={randomWord}
          onNextWord={loadRandomWord}
          isLoading={isRandomLoading || (isLoading && !randomWord)}
        />

        {/* Quick Stats Tiles */}
        <StatsOverview
          totalVocab={totalVocab}
          totalCollections={totalCollections}
          newThisWeek={newThisWeek}
        />

        {/* Charts & Analytics */}
        <div className="flex flex-col gap-6">
          <StreakChart data={dailyStats} />

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <LevelDistribution data={levelStats} />
            <CollectionDistribution data={collectionStats} />
          </div>
        </div>
      </div>
    </>
  );
}
