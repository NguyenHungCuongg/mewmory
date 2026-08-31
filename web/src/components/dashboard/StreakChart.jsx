import {
  ResponsiveContainer,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
} from "recharts";

export default function StreakChart({ data = [] }) {
  if (!data || data.length === 0) return null;

  return (
    <div className="card-taupe p-6 rounded-card flex flex-col gap-4">
      <div className="flex items-center justify-between">
        <h3 className="text-subheading font-display font-light text-ink">
          📈 Tiến độ thêm từ (14 ngày gần nhất)
        </h3>
      </div>

      <div className="h-56 w-full pt-2">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={data} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
            <XAxis
              dataKey="date"
              stroke="#a59f97"
              fontSize={12}
              tickLine={false}
              axisLine={{ stroke: "#ebe8e4" }}
            />
            <YAxis
              allowDecimals={false}
              stroke="#a59f97"
              fontSize={12}
              tickLine={false}
              axisLine={{ stroke: "#ebe8e4" }}
            />
            <Tooltip
              contentStyle={{
                backgroundColor: "#fdfcfc",
                borderColor: "#ebe8e4",
                borderRadius: "12px",
                boxShadow: "rgba(0, 0, 0, 0.04) 0px 2px 4px",
                fontSize: "13px",
                color: "#000000",
              }}
              formatter={(val) => [`${val} từ`, "Đã thêm"]}
              labelFormatter={(label) => `Ngày ${label}`}
            />
            <Bar
              dataKey="count"
              fill="#000000"
              radius={[4, 4, 0, 0]}
              maxBarSize={32}
            />
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}
