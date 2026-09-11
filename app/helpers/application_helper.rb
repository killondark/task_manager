module ApplicationHelper
  def flash_class(type)
    case type.to_sym
    when :alert
      "bg-red-50 text-red-700 border border-red-200"
    when :notice
      "bg-emerald-50 text-emerald-700 border border-emerald-200"
    else
      "bg-slate-100 text-slate-700 border border-slate-200"
    end
  end
end
