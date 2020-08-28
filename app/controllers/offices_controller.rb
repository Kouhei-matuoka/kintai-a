class OfficesController < ApplicationController
   before_action :logged_in_user, only: %i(index create update destroy)
   before_action :admin_user, only: %i(index create update destroy)
   before_action :set_offise, only: %i(update destroy)
   
  def index
    @offices = Office.all
    @office = Office.new
  end
  
  def create
    @office = Office.new(office_params)
    if @office.save
      flash[:success] = "#{@office.office_name}を登録しました。"
      redirect_to offices_url
    else
      flash[:danger] = "拠点登録に失敗しました、入力エラーが#{@office.errors.count}件あります。<br>" + @office.errors.full_messages.join("<br>")
      redirect_to offices_url
    end
  end
  
  def update
    if @office.update_attributes(office_params)
      flash[:success] = "#{@office.office_name}の情報を更新しました。"
      redirect_to offices_url
    elsif @office.office_name.blank?
      flash[:danger] = "更新に失敗しました。<br>" + @office.errors.full_messages.join("<br>")
      redirect_to offices_url
    else
      flash[:danger] = "#{@office.office_name}の更新に失敗しました。<br>" + @office.errors.full_messages.join("<br>")
      redirect_to offices_url
    end
  end
  
  def destroy
    @office.destroy
    flash[:danger] = "#{@office.office_name}のデータを削除しました。"
    redirect_to offices_url
  end
  
  private
  
    def office_params
      params.require(:office).permit(:office_number, :office_name, :attendance_type)
    end
    
    def set_offise
      @office = Office.find(params[:id])
    end
end