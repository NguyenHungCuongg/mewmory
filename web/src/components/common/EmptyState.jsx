import { IconBook } from "./Icons";

export default function EmptyState({
  icon = null,
  title = "Chưa có dữ liệu",
  description = "Bắt đầu thêm dữ liệu mới để bắt đầu học tập và theo dõi tiến độ của bạn.",
  action = null,
}) {
  return (
    <div className="card-taupe p-12 rounded-card-lg text-center flex flex-col items-center justify-center max-w-lg mx-auto my-6 animate-fade-in">
      <div className="w-16 h-16 rounded-full bg-eggshell border border-stone flex items-center justify-center text-graphite mb-4 shadow-subtle">
        {icon || <IconBook className="w-7 h-7 text-smoke" />}
      </div>
      <h3 className="text-heading-sm font-display font-light text-ink">
        {title}
      </h3>
      {description && (
        <p className="text-body-sm text-smoke mt-2 max-w-sm">
          {description}
        </p>
      )}
      {action && <div className="mt-6">{action}</div>}
    </div>
  );
}
