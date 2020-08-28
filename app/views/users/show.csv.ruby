require 'csv'
CSV.generate do |csv|
  column_names = %w(日付 曜日 出社時間 退社時間 在社時間)
  csv << column_names
  @attendances.each do |day|
    column_values = [
      l(day.worked_on, format: :short),
      $days_of_the_week[day.worked_on.wday],
      (day.changed_started_at.floor_to(15.minutes).strftime("%H:%M") if day.changed_started_at.present? && day.change_status != "申請中" && day.change_status != "否認"),
      (day.changed_finished_at.floor_to(15.minutes).strftime("%H:%M") if day.changed_finished_at.present? && day.change_status != "申請中" && day.change_status != "否認"),
      (format("%.2f", working_times(day.changed_started_at.floor_to(15.minutes), day.changed_finished_at.floor_to(15.minutes), day.change_next_day_check)) if
      day.changed_started_at.present? && day.changed_finished_at.present? && day.change_status != "申請中" && day.change_status != "否認")
    ]
    csv << column_values
  end
end