import {
  ResponsiveContainer,
  LineChart,
  Line,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  CartesianGrid,
} from "recharts";

export function LineUsageChart({ data, xKey, yKey, label }) {
  return (
    <ResponsiveContainer width="100%" height={200}>
      <LineChart data={data} margin={{ top: 4, right: 8, bottom: 0, left: -20 }}>
        <CartesianGrid strokeDasharray="3 3" stroke="#ffffff10" />
        <XAxis dataKey={xKey} tick={{ fill: "#9ca3af", fontSize: 11 }} />
        <YAxis tick={{ fill: "#9ca3af", fontSize: 11 }} />
        <Tooltip
          contentStyle={{ background: "#1f2937", border: "none", borderRadius: 8 }}
          labelStyle={{ color: "#f9fafb" }}
          itemStyle={{ color: "#818cf8" }}
        />
        <Line
          type="monotone"
          dataKey={yKey}
          name={label}
          stroke="#818cf8"
          strokeWidth={2}
          dot={false}
        />
      </LineChart>
    </ResponsiveContainer>
  );
}

export function BarUsageChart({ data, xKey, yKey, label }) {
  return (
    <ResponsiveContainer width="100%" height={200}>
      <BarChart data={data} margin={{ top: 4, right: 8, bottom: 0, left: -20 }}>
        <CartesianGrid strokeDasharray="3 3" stroke="#ffffff10" />
        <XAxis dataKey={xKey} tick={{ fill: "#9ca3af", fontSize: 11 }} />
        <YAxis tick={{ fill: "#9ca3af", fontSize: 11 }} />
        <Tooltip
          contentStyle={{ background: "#1f2937", border: "none", borderRadius: 8 }}
          labelStyle={{ color: "#f9fafb" }}
          itemStyle={{ color: "#818cf8" }}
        />
        <Bar dataKey={yKey} name={label} fill="#818cf8" radius={[4, 4, 0, 0]} />
      </BarChart>
    </ResponsiveContainer>
  );
}
