module SessionsHelper
  
  # ログイン用
  def log_in(user)
    session[:user_id] = user.id
  end

  # 永続的セッションを記憶
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # 永続的セッションを破棄
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # ログアウト用 セッションと@current_userを破棄
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  # 現在ログイン中のユーザーの値を返す
  # それ以外の場合はcookiesに対応するユーザを返す
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    else (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end
  
  # 渡されたユーザーがログイン済みのユーザーならtrue
  def current_user?(user)
    user == current_user
  end

  # 現在ログイン中のユーザーがいればtrue、いなければfalse
  def logged_in?
    !current_user.nil?
  end
  
  # 記憶しているURLまたはデフォルトURLにリダイレクト
  def redirect_back_or(default_url)
    redirect_to(session[:forwarding_url] || default_url)
    session.delete(:forwarding_url)
  end

  # アクセスしようとしたURLを記憶
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end