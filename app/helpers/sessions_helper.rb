module SessionsHelper

  # ログイン用
  def log_in(user)
    session[:user_id] = user.id
  end

  # ログアウト用 セッションと@current_userを破棄
  def log_out
    session.delete(:user_id)
    @current_user = nil
  end

  # 現在ログイン中のユーザーの値を返す
  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end

  # 現在ログイン中のユーザーがいればtrue、いなければfalse
  def logged_in?
    !current_user.nil?
  end
end