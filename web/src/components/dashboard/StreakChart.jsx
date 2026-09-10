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

export default function StreakChart({ data = [] }) {
  const { t } = useTranslation("dashboard");
  const { axisStroke, axisLine, tooltipBg, tooltipBorder, tooltipText, tooltipShadow, barFillPrimary } =
    useChartColors();

  if (!data || data.length === 0) return null;

  return (
    <div className="card-taupe p-6 rounded-card flex flex-col gap-4">
      <div className="flex items-center justify-between">
        <h3 className="text-subheading font-display font-light text-ink">
          {t("charts.wordsAddedProgress")}
        </h3>
      </div>

      <div className="h-56 w-full pt-2">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={data} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
            <XAxis
              dataKey="date"
              stroke={axisStroke}
              fontSize={12}
              tickLine={false}
              axisLine={{ stroke: axisLine }}
            />
            <YAxis
              allowDecimals={false}
              stroke={axisStroke}
              fontSize={12}
              tickLine={false}
              axisLine={{ stroke: axisLine }}
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
              formatter={(val) => [t("charts.wordsCount", { count: val }), t("charts.added")]}
              labelFormatter={(label) => t("charts.dateLabel", { label })}
            />
            <Bar
              dataKey="count"
              fill={barFillPrimary}
              radius={[4, 4, 0, 0]}
              maxBarSize={32}
            />
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}

