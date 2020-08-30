class AttendancesController < ApplicationController
  before_action :set_user, only: %i(edit_one_month update_one_month update_one_month_apply one_month_apply confirmation_one_month_apply
                                    edit_overtime_work_apply update_overtime_work_apply recive_overtime_work_apply confirmation_overtime_work_apply
                                    recive_change_attendance_apply confirmation_change_attendance_apply edit_log)
  before_action :logged_in_user, only: %i(update edit_one_month update_one_month one_month_apply update_one_month_apply confirmation_one_month_apply
                                          edit_overtime_work_apply update_overtime_work_apply recive_overtime_work_apply confirmation_overtime_work_apply
                                          recive_change_attendance_apply confirmation_change_attendance_apply edit_log)
  before_action :superior_user, only: %i(one_month_apply confirmation_one_month_apply recive_overtime_work_apply confirmation_overtime_work_apply
                                        recive_change_attendance_apply confirmation_change_attendance_apply)
  before_action :correct_user, only: %i(update_one_month_apply edit_overtime_work_apply recive_overtime_work_apply confirmation_overtime_work_apply
                                        recive_change_attendance_apply confirmation_change_attendance_apply edit_log)
  before_action :admin_or_correct_user, only: %i(edit_one_month update_one_month)
  before_action :admin_exclusion, only: %i(update edit_one_monthupdate_one_month update_one_month_apply one_month_apply confirmation_one_month_apply
                                           edit_overtime_work_apply recive_overtime_work_apply confirmation_overtime_work_apply
                                           recive_change_attendance_apply confirmation_change_attendance_apply edit_log)
  before_action :set_one_month, only: %i(edit_one_month edit_overtime_work_apply recive_overtime_work_apply confirmation_overtime_work_apply
                                        recive_change_attendance_apply confirmation_change_attendance_apply edit_log)
  before_action :set_one_month_apply, only: %i(update_one_month_apply)

  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  INVALID_MSG = "無効な入力データがあった為、更新をキャンセルしました。"

  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0), changed_started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0), changed_finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end
  
  def edit_one_month
    @superiors = superior_without_me
  end
  
  def update_one_month
    ActiveRecord::Base.transaction do
      if attendances_invalid?
        attendances_params.each do |id, item|
          attendance = Attendance.find(id)
          if item[:change_superior_id].present?
            attendance.update_attributes!(item)
            attendance.update_attributes!(change_superior_name: User.find(item[:change_superior_id]).name)
          end
        end
        flash[:success] = "1ヶ月分の勤怠情報を更新しました。"
        redirect_to user_url(date: params[:date])
      else
        flash[:danger] = "#{INVALID_MSG}#{@msg}"
        redirect_to attendances_edit_one_month_user_url(date: params[:date])
      end
    end
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "#{INVALID_MSG}#{@msg}"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end

  def one_month_apply
    @users = month_applying_employee # 1ヶ月勤怠申請中の社員を@usersに代入
  end
  
  # 1ヶ月の勤怠申請提出
  def update_one_month_apply
    if selected_superior? # 申請先の上長が選択されているか？
      month_apply_params.each do |id, item|
        attendance = Attendance.find(id)
        attendance.update_attributes!(item)
        item[:superior_name] = User.find(item[:superior_id]).name
        attendance.update_attributes!(item)
        @month_apply = item[:month_apply].to_date.strftime("%-m")
        @superior = item[:superior_name]
      end
      flash[:success] = "#{@user.name}の#{@month_apply}月分勤怠申請を、#{@superior}へ提出しました。"
      redirect_to user_url(date: params[:date])
    else
      flash[:danger] = "申請先の上長を選択してください。"
      redirect_to user_url(date: params[:date])
    end
  end
  
  # 1ヶ月の勤怠申請承認
  def confirmation_one_month_apply
    confirmation_month_apply_params.each do |id, item|
      if apply_confirmed_invalid?(item[:status], item[:month_check])
        attendance = Attendance.find(id)
        attendance.update_attributes(item)
        if item[:status] == "否認"
          item[:month_approval] = 2
          item[:month_check] = "0"
          attendance.update_attributes(item)
        end
      end
    end
    flash[:success] = "1ヶ月勤怠申請の決裁を更新しました。"
    redirect_back(fallback_location: root_path) # 申請月のページにリダイレクト、エラーが出る前にroot_pathにとんでくれる。
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "エラーが発生した為、1ヶ月勤怠申請の更新がキャンセルされました。"
    redirect_back(fallback_location: root_path)
  end
  
  # 残業申請提出ページ
  def edit_overtime_work_apply
    @superiors = superior_without_me
  end
  
  # 残業申請提出
  def update_overtime_work_apply
    overtime_work_apply_params.each do |id, item|
      if selected_overtime_superior?
        attendance = Attendance.find(id)
        attendance.update_attributes(item) unless time_select_invalid?(item)
        if attendance.next_day_check == "1"
          next_day_times(@user.designated_work_end_time, attendance.overtime_end_plan)
        else
          overwotking_times(@user.designated_work_end_time, attendance.overtime_end_plan)
        end
        attendance.update_attributes(overtime_hours: @total_time, overtime_superior_name: User.find(item[:overtime_superior_id]).name)
        flash[:success] = "#{attendance.overtime_superior_name}に残業申請を提出しました。"
        redirect_back(fallback_location: root_path)
      else
        msg_a = "申請先上長を選択してください。" if item[:overtime_superior_id].blank?
        msg_b = "業務処理内容を入力してください。" if item[:overtime_detail].blank?
        flash[:danger] = "#{msg_a}#{msg_b}"
        redirect_back(fallback_location: root_path)
      end
    end
  end
  
  # 残業申請確認ページ
  def recive_overtime_work_apply
    @users = overtime_applying_employee
  end
  
  # 残業申請承認
  def confirmation_overtime_work_apply
    confirmation_overtime_work_apply_params.each do |id, item|
      if apply_confirmed_invalid?(item[:overtime_status], item[:overtime_check])
        attendance = Attendance.find(id)
        attendance.update_attributes(item) unless time_select_invalid?(item)
        if item[:overtime_status] == "否認"
          item[:overtime_approval] = 2
          item[:overtime_check] = "0"
          attendance.update_attributes(item)
        end
      end
    end
    flash[:success] = "残業申請の決裁を更新しました。"
    redirect_to @user
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "エラーが発生した為、残業申請の更新がキャンセルされました。"
    redirect_to root_path
  end
  
  # 勤怠変更確認ページ
  def recive_change_attendance_apply
    @users = change_applying_employee
  end
  
  # 勤怠変更承認
  def confirmation_change_attendance_apply
    ActiveRecord::Base.transaction do
      confirmation_attendances_params.each do |id, item|
        if apply_confirmed_invalid?(item[:change_status], item[:change_check])
          attendance = Attendance.find(id)
          item[:approval_date] = Time.current
          attendance.update_attributes(item)
          if item[:change_status] == "否認"
            item[:change_approval] = 2
            item[:change_check] = "0"
            item[:approval_date] = nil
            attendance.update_attributes(item)
          elsif item[:change_status] == "なし"
              item[:change_approval] = 1
              item[:change_check] = "0"
              item[:approval_date] = nil
              attendance.update_attributes(item)
          end
        end
      end
      flash[:success] = "勤怠変更の決裁を更新しました。"
      redirect_to user_url(date: params[:date])
    end
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "エラーが発生した為、勤怠変更の更新がキャンセルされました。"
    redirect_to root_path
  end
  
  def edit_log
    @superiors = change_superior
    
    # date_selectの選択年月範囲
    if Attendance.where(user_id: @user.id).where.not(calendar_day: nil).present?
      @start_year =  Attendance.where(user_id: @user.id).minimum(:calendar_day).year
      @end_year = Attendance.where(user_id: @user.id).maximum(:calendar_day).year
    end
    
    @logs =
    if params[:search].blank?
      Attendance.where(user_id: @user.id).where(worked_on: @first_day..@last_day).where(change_approval: 3).order(worked_on: "ASC")
    else
      search_years = ActiveSupport::HashWithIndifferentAccess.new(worked_on: params[:search]["worked_on(1i)"])
      search_months = ActiveSupport::HashWithIndifferentAccess.new(worked_on: params[:search]["worked_on(2i)"])
      @search_year = search_years[:worked_on]
      @search_month = search_months[:worked_on]
      Attendance.where(user_id: @user.id).search(params[:search]["worked_on(1i)"]).search(params[:search]["worked_on(2i)"]).where(change_approval: 3).order(worked_on: "ASC")
    end
  end
  
  private
    
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :changed_started_at, :changed_finished_at,
                                                 :note, :change_superior_id, :change_status, :change_check,
                                                 :change_approval, :change_next_day_check, :calendar_day])[:attendances]
    end
    
    # 勤怠変更申請承認
    def confirmation_attendances_params
      params.permit(attendances: [:change_status, :change_approval, :change_check])[:attendances]
    end
    
    # 1ヶ月の勤怠申請
    def month_apply_params
      params.permit(attendances: [:superior_id, :superior_name, :status, :month_apply, :month_approval, :month_check])[:attendances]
    end
    
    # 1ヶ月の勤怠申請承認
    def confirmation_month_apply_params
      params.permit(attendances: [:status, :month_approval, :month_check])[:attendances]
    end
    
    # 残業申請提出
    def overtime_work_apply_params
      params.require(:user).permit(attendances: [:overtime_superior_id, :overtime_end_plan, :next_day_check, :overtime_detail,
                                  :overtime_hours, :overtime_approval, :overtime_status, :overtime_check, :overtime_approval ])[:attendances]
    end
    
    # 残業申請承認
    def confirmation_overtime_work_apply_params
      params.permit(attendances: [:overtime_status, :overtime_check, :overtime_approval])[:attendances]
    end
end