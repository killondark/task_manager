module TasksHelper
  def status_badge_class(status)
    case status.to_s
    when "todo"
      "bg-slate-100 text-slate-700"
    when "in_progress"
      "bg-blue-100 text-blue-700"
    when "done"
      "bg-emerald-100 text-emerald-700"
    else
      "bg-slate-100 text-slate-700"
    end
  end

  def status_count_color(status)
    case status.to_s
    when "in_progress"
      "text-blue-600"
    when "done"
      "text-emerald-600"
    else
      "text-slate-700"
    end
  end

  def priority_indicator_class(priority)
    case priority.to_i
    when 1..2
      "bg-emerald-500"
    when 3
      "bg-amber-500"
    when 4..5
      "bg-red-500"
    else
      "bg-slate-300"
    end
  end

  def priority_label(priority)
    priority.to_i.positive? ? priority.to_i : nil
  end
end
