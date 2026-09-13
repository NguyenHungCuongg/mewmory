import {
  ResponsiveContainer,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
} from "recharts";
import { useTranslation } from "react-i18next";
import { useChartColors } from "../../hooks/useChartColors";

export default function CollectionDistribution({ data = [] }) {
  const { t } = useTranslation("dashboard");
  const { axisStroke, tooltipBg, tooltipBorder, tooltipShadow, tooltipText, barFillSecondary } =
    useChartColors();

  if (!data || data.length === 0) {
    return (
      <div className="card-taupe p-6 rounded-card flex flex-col items-center justify-center min-h-[260px] text-center">
        <h3 className="text-subheading font-display font-light text-ink mb-2">
          {t("charts.collectionDistribution")}
        </h3>
        <p className="text-body-sm text-smoke">{t("charts.noCollectionData")}</p>
      </div>
    );
  }

  const chartData = data.slice(0, 6); // top 6 collections

  return (
    <div className="card-taupe p-6 rounded-card flex flex-col gap-4">
      <h3 className="text-subheading font-display font-light text-ink">
        {t("charts.collectionDistribution")}
      </h3>

      <div className="h-60 w-full pt-2">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart
            data={chartData}
            layout="vertical"
            margin={{ top: 5, right: 20, left: 20, bottom: 5 }}
          >
            <XAxis type="number" allowDecimals={false} stroke={axisStroke} fontSize={12} />
            <YAxis
              dataKey="name"
              type="category"
              stroke={axisStroke}
              fontSize={12}
              width={90}
              tickFormatter={(v) => (v.length > 10 ? `${v.substring(0, 10)}...` : v)}
            />
            <Tooltip
              contentStyle={{
                backgroundColor: tooltipBg,
                borderColor: tooltipBorder,
                borderRadius: "12px",
                boxShadow: tooltipShadow,
                fontSize: "13px",
                color: tooltipText,
              }}
              itemStyle={{ color: tooltipText }}
              labelStyle={{ color: tooltipText, fontWeight: 500 }}
              formatter={(val) => [
                t("charts.wordsCount", { count: val }),
                t("charts.quantity"),
              ]}
            />
            <Bar dataKey="count" fill={barFillSecondary} radius={[0, 4, 4, 0]} maxBarSize={20} />
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}

