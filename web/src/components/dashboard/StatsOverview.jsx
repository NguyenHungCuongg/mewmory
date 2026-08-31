import { Link } from "react-router-dom";

export default function StatsOverview({ totalVocab, totalCollections, newThisWeek }) {
  return (
    <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
      <Link
        to="/vocabulary"
        className="card-taupe p-5 rounded-card flex flex-col justify-between hover:border-graphite/20 transition-all"
      >
        <span className="text-body-sm text-smoke font-medium">
          Tổng số từ vựng
        </span>
        <div className="flex items-baseline justify-between mt-3">
          <span className="text-heading font-display font-light text-ink">
            {totalVocab}
          </span>
          <span className="text-caption text-ash">Xem tất cả →</span>
        </div>
      </Link>

      <Link
        to="/collections"
        className="card-taupe p-5 rounded-card flex flex-col justify-between hover:border-graphite/20 transition-all"
      >
        <span className="text-body-sm text-smoke font-medium">
          Bộ sưu tập
        </span>
        <div className="flex items-baseline justify-between mt-3">
          <span className="text-heading font-display font-light text-ink">
            {totalCollections}
          </span>
          <span className="text-caption text-ash">Quản lý →</span>
        </div>
      </Link>

      <div className="card-taupe p-5 rounded-card flex flex-col justify-between">
        <span className="text-body-sm text-smoke font-medium">
          Từ mới (14 ngày qua)
        </span>
        <div className="flex items-baseline justify-between mt-3">
          <span className="text-heading font-display font-light text-ink">
            {newThisWeek}
          </span>
          <span className="text-caption text-green-700 font-medium">
            🔥 Đang học
          </span>
        </div>
      </div>
    </div>
  );
}
