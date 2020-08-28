class UsersController < ApplicationController
  before_action :set_user, only: %i(show edit update destroy attend_employees edit_basic_info)
  before_action :logged_in_user, only: %i(index show edit update destroy attend_employees edit_basic_info import)
  before_action :admin_user, only: %i(index destroy attend_employees edit_basic_info)
  before_action :correct_or_superior_user, only: %i(show)
  before_action :admin_exclusion, only: %i(show)
  before_action :set_one_month, only: %i(show attend_employees)

  def index
    if params[:search] == ""
      redirect_to users_url
      flash[:danger] = "キーワードを入力してください。"
    else
      @users = User.paginate(page: params[:page]).search(params[:search]).order(id: "ASC").where.not(admin: true)
      if params[:search].present?
        flash.now[:success] = "検索結果:#{@users.count}件"
      end
    end
  end
  
  def import
    if params[:csv_file].blank?
      flash[:danger] = "インポートするCSVファイルを選択してください。"
      redirect_to users_url
    else
      num = User.import(params[:csv_file])
      if num > 0
        flash[:success] = "#{num.to_s}件のユーザー情報を追加/更新しました。"
        redirect_to users_url
      else
        flash[:danger] = "読み込みエラーが発生しました。"
        redirect_to users_url
      end
    end
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "ユーザーの新規登録に成功しました。"
      redirect_to @user
    else
      render :new
    end
  end
  
  def show
    @worked_sum = @attendances.where.not(started_at: nil).count
    @superiors = superior_without_me
    @superiors_all = superior_add_me
    @month = set_one_month_apply
    
    respond_to do |format|
      format.html
      format.csv do
          send_data render_to_string.encode(Encoding::Windows_31J, undef: :replace, row_sep: "\r\n", force_quotes: true),
          filename: "#{@user.name}(#{l(@first_day, format: :middle)})勤怠情報.csv", type: :csv
      end
    end
  end
  
  def edit
  end
  
  def update
    unless @user.admin?
      if @user.update_attributes(user_params)
        flash[:success] = "#{@user.name}の情報を更新しました。"
        redirect_to users_url
      elsif @user.name.blank?
        flash[:danger] = "更新に失敗しました。<br>" + @user.errors.full_messages.join("<br>")
        redirect_to users_url
      else
        flash[:danger] = "#{@user.name}の更新に失敗しました。<br>" + @user.errors.full_messages.join("<br>")
        redirect_to users_url
      end
    else
      redirect_to users_url
    end
  end
  
  def destroy
    unless @user.admin?
      @user.destroy
      flash[:success] = "#{@user.name}のデータを削除しました。"
      redirect_to users_url
    else
      redirect_to users_url
    end
  end
  
  def attend_employees
    @users = working_users
  end
  
  def edit_basic_info
  end
  
  private
  
    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :employee_number, :uid, :superior, :admin, :password, :password_confirmation)
    end
    
    def basic_info_params
      params.require(:user).permit(:affiliation, :basic_work_time, :work_time)
    end
end