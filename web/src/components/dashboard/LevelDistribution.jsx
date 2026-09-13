import {
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  Tooltip,
  Legend,
} from "recharts";
import { useTranslation } from "react-i18next";
import { useChartColors } from "../../hooks/useChartColors";

const LEVEL_COLORS = {
  A1: "#86efac",
  A2: "#4ade80",
  B1: "#93c5fd",
  B2: "#60a5fa",
  C1: "#c084fc",
  C2: "#a855f7",
  Unranked: "#d6d3d1",
};

export default function LevelDistribution({ data = [] }) {
  const { t } = useTranslation("dashboard");
  const { tooltipBg, tooltipBorder, tooltipShadow, tooltipText, legendText } =
    useChartColors();

  if (!data || data.length === 0) {
    return (
      <div className="card-taupe p-6 rounded-card flex flex-col items-center justify-center min-h-[260px] text-center">
        <h3 className="text-subheading font-display font-light text-ink mb-2">
          {t("charts.levelDistribution")}
        </h3>
        <p className="text-body-sm text-smoke">{t("charts.noLevelData")}</p>
      </div>
    );
  }

  return (
    <div className="card-taupe p-6 rounded-card flex flex-col gap-4">
      <h3 className="text-subheading font-display font-light text-ink">
        {t("charts.levelDistribution")}
      </h3>

      <div className="h-60 w-full">
        <ResponsiveContainer width="100%" height="100%">
          <PieChart>
            <Pie
              data={data}
              dataKey="count"
              nameKey="level"
              cx="50%"
              cy="50%"
              innerRadius={50}
              outerRadius={80}
              paddingAngle={4}
            >
              {data.map((entry, index) => (
                <Cell
                  key={`cell-${index}`}
                  fill={LEVEL_COLORS[entry.level] || "#a59f97"}
                />
              ))}
            </Pie>
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
              formatter={(val, name) => [
                t("charts.wordsCount", { count: val }),
                t("charts.level", { level: name }),
              ]}
            />
            <Legend
              verticalAlign="bottom"
              height={36}
              iconType="circle"
              formatter={(value) => (
                <span style={{ color: legendText }} className="text-caption font-medium">
                  {value}
                </span>
              )}
            />
          </PieChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}

