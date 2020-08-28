module AttendancesHelper
  
  def attendance_attend(attendance)
    if Date.current == attendance.worked_on
      return '出社' if attendance.started_at.nil?
    end
    false
  end
  
  def attendance_leave(attendance)
    if Date.current == attendance.worked_on
      return '退社' if attendance.started_at.present? && attendance.finished_at.nil?
    end
    false
  end
  
  def attendances_invalid?
    attendances = true
    attendances_params.each do |id, item|
      if item[:change_superior_id].blank?
        next
      elsif item[:change_superior_id].present? && item[:note].blank?
        attendances = false
        if item[:note].blank?
          @msg = "備考を入力してください。"
        end
        break
      elsif item[:change_superior_id].present? && item[:note].present? && item['changed_started_at(4i)'] == "" && item['changed_started_at(5i)'] == "" && item['changed_finished_at(4i)'] == "" && item['changed_finished_at(5i)'] == ""
        attendances = false
        break
      elsif item[:change_superior_id].present? && item[:note].present? && item['changed_started_at(4i)'] == "" || item['changed_started_at(5i)'] == "" || item['changed_finished_at(4i)'] == "" || item['changed_finished_at(5i)'] == ""
        attendances = false
        break
      elsif item['changed_started_at(4i)'] > item['changed_finished_at(4i)'] && item[:change_next_day_check] == "0"
        attendances = false
        break
      elsif
        item['changed_started_at(4i)'] == item['changed_finished_at(4i)'] && item['changed_started_at(5i)'] > item['changed_finished_at(5i)'] && item[:change_next_day_check] == "0"
        attendances = false
        break
      end
    end
    return attendances
  end
  
  # 上長選択とtime_selectに任意の値が入力されていない場合の評価
  def time_select_invalid?(item)
    item[:change_superior_id].present? && item["started_at(4i)"] == "" && item["started_at(5i)"] == "" && item["finished_at(4i)"] == "" && item["finished_at(5i)"] == ""
  end
  
  # 本日の勤務中社員取得用
  def working_users
    User.where(id: Attendance.where.not(started_at: nil).
         where(id: Attendance.where(finished_at: nil)).
         where(id: Attendance.where(worked_on: Date.current)).select(:user_id))
  end
  
  # 1ヶ月の勤怠申請用
  def set_one_month_apply
    @user.attendances.where('worked_on >= ? and worked_on <= ?', @first_day, @last_day).order('worked_on')
  end
  
  # 1ヶ月勤怠申請中の社員を取得
  def month_applying_employee
    User.joins(:attendances).where.not(attendances: {superior_id: nil}).where(attendances: {month_approval: 2}).distinct
  end
  
  # 1ヶ月勤怠申請済の社員を取得
  def month_applicated_employee
    User.joins(:attendances).where.not(attendances: {superior_id: nil}).where(attendances: {month_approval: 3}).distinct
  end
  
  # 自分以外の上長
  def superior_without_me
    User.where(superior: true).where.not(id: current_user.id)
  end
  
  # 自分を含めたの上長
  def superior_add_me
    User.where(superior: true)
  end
  
  # 1ヶ月勤怠申請先の上長の選択されているか？
  def selected_superior?
    superior = true
    month_apply_params.each do |id, item|
      if item[:superior_id].blank? && [:month_apply].present?
        superior = false
      elsif item[:superior_id].present? && [:month_apply].present?
        superior = true
        break
      end
    end
    superior
  end
  
  # 1ヶ月勤怠申請が自分にきているか
  def has_month_apply
    User.joins(:attendances).where(attendances: {superior_id: current_user.id}).where(attendances: {status: "申請中"})
  end
  
  # 勤怠申請決裁の変更のチェックが入っているか？
  def apply_confirmed_invalid?(status, check)
    if (status == "承認" || status == "否認")  && check == "1"
      confirmed = true
    else
      confirmed = false
    end
    confirmed
  end
  
  # 1ヶ月申請フォームのステータス表示
  def apply_status(status)
    case status
    when "申請中"
      "に申請中"
    when "承認"
      "から承認済"
    when "否認"
      "から否認"
    else
      "未"
    end
  end
  
  # 1ヶ月申請ボタンフォームのステータス表示
  def apply_btn_status(status)
    case status
    when "申請中"
      "申請先を変更"
    when "承認"
      "再申請"
    when "否認"
      "再申請"
    else
      "申請"
    end
  end


  # 残業申請先の上長の選択されているか？業務処理内容が入力されているか？
  def selected_overtime_superior?
    superior = true
    overtime_work_apply_params.each do |id, item|
      if item[:overtime_superior_id].blank? || item[:overtime_detail].blank?
        superior = false
      elsif item[:overtime_superior_id].present? && item[:overtime_detail].present?
        superior = true
        break
      end
    end
    superior
  end
  
  # 残業申請中の社員を取得
  def overtime_applying_employee
    User.joins(:attendances).where.not(attendances: {overtime_superior_id: nil}).where(attendances: {overtime_approval: 2}).distinct
  end
  
  def working_times(start, finish, next_day)
    if next_day == "1"
      # format("%.2f", (24 - ((start - finish) / 60) / 60.0))
      hour = (24 - start.hour) + finish.hour
      min = finish.min - start.min
      @total_time = hour + min / 60.00
    elsif
      # format("%.2f", (((finish - start) / 60) / 60.0))
      hour = finish.hour - start.hour
      min = finish.min - start.min
      @total_time = hour + min / 60.00
    end
  end
  
  # 残業申請時間外時間の計算
  def overwotking_times(basic, end_plan)
    hour = end_plan.hour - basic.hour
    min = end_plan.min - basic.min
    @total_time = hour + min / 60.00
  end
  
  # 翌日にまたがる残業申請時間外時間の計算
  def next_day_times(start, finish)
    hour = (24 - start.hour) + finish.hour
    min = finish.min - start.min
    @total_time = hour + min / 60.00
  end
  
  # 残業申請が自分にきているか
  def has_overtime_apply
    User.joins(:attendances).where(attendances: {overtime_superior_id: current_user.id}).where(attendances: {overtime_status: "申請中"})
  end
  
  # 残業申請のステータス表示
  def overtime_status_text(status)
    case status
    when "申請中"
      "　残業申請中"
    when "否認"
      "　残業否認"
    when "承認"
      "　残業承認"
    else
    end
  end
  
  # 勤怠変更申請中の社員を取得
  def change_applying_employee
    User.joins(:attendances).where.not(attendances: {change_superior_id: nil}).
                             where(attendances: {change_approval: 2}).distinct
  end
  
  # 勤怠変更申請が自分にきているか
  def has_change_apply
    User.joins(:attendances).where(attendances: {change_superior_id: current_user.id}).where(attendances: {change_status: "申請中"})
  end
  
  # 勤怠変更申請のステータス表示
  def change_status_text(status)
    case status
    when "申請中"
      "　勤怠編集申請中"
    when "否認"
      "　勤怠編集否認"
    when "承認"
      "　勤怠編集承認︎︎"
    when "なし"
    else
    end
  end
  
  # 勤怠ログの上長
  def change_superior
    User.where(superior: true)
  end
end