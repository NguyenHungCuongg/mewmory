import {
  ResponsiveContainer,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
} from "recharts";

export default function CollectionDistribution({ data = [] }) {
  if (!data || data.length === 0) {
    return (
      <div className="card-taupe p-6 rounded-card flex flex-col items-center justify-center min-h-[260px] text-center">
        <h3 className="text-subheading font-display font-light text-ink mb-2">
          Từ vựng theo bộ sưu tập
        </h3>
        <p className="text-body-sm text-smoke">Chưa có bộ sưu tập nào</p>
      </div>
    );
  }

  const chartData = data.slice(0, 6); // top 6 collections

  return (
    <div className="card-taupe p-6 rounded-card flex flex-col gap-4">
      <h3 className="text-subheading font-display font-light text-ink">
        📁 Từ vựng theo bộ sưu tập
      </h3>

      <div className="h-60 w-full pt-2">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart
            data={chartData}
            layout="vertical"
            margin={{ top: 5, right: 20, left: 20, bottom: 5 }}
          >
            <XAxis type="number" allowDecimals={false} stroke="#a59f97" fontSize={12} />
            <YAxis
              dataKey="name"
              type="category"
              stroke="#a59f97"
              fontSize={12}
              width={90}
              tickFormatter={(v) => (v.length > 10 ? `${v.substring(0, 10)}...` : v)}
            />
            <Tooltip
              contentStyle={{
                backgroundColor: "#fdfcfc",
                borderColor: "#ebe8e4",
                borderRadius: "12px",
                boxShadow: "rgba(0, 0, 0, 0.04) 0px 2px 4px",
                fontSize: "13px",
              }}
              formatter={(val) => [`${val} từ`, "Số lượng"]}
            />
            <Bar dataKey="count" fill="#777169" radius={[0, 4, 4, 0]} maxBarSize={20} />
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}
