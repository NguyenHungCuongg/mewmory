import {
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  Tooltip,
  Legend,
} from "recharts";

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
  if (!data || data.length === 0) {
    return (
      <div className="card-taupe p-6 rounded-card flex flex-col items-center justify-center min-h-[260px] text-center">
        <h3 className="text-subheading font-display font-light text-ink mb-2">
          Phân bố trình độ (CEFR)
        </h3>
        <p className="text-body-sm text-smoke">Chưa có dữ liệu phân loại</p>
      </div>
    );
  }

  return (
    <div className="card-taupe p-6 rounded-card flex flex-col gap-4">
      <h3 className="text-subheading font-display font-light text-ink">
        🎯 Phân bố theo trình độ (CEFR)
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
                backgroundColor: "#fdfcfc",
                borderColor: "#ebe8e4",
                borderRadius: "12px",
                boxShadow: "rgba(0, 0, 0, 0.04) 0px 2px 4px",
                fontSize: "13px",
              }}
              formatter={(val, name) => [`${val} từ`, `Level ${name}`]}
            />
            <Legend
              verticalAlign="bottom"
              height={36}
              iconType="circle"
              formatter={(value) => (
                <span className="text-caption text-graphite font-medium">
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
