class UsersController
  before_filter :authenticate, except: :redirect

  def start_sendind
    User.where(status: User.statuses[:in_line]).first.send_message
    redirect_to root_path, notice: 'Sending started'
  end


  def redirect
    message = Message.find(SecureId.new(deliver_params[:message]).decrypt)
    User.find(SecureId.new(deliver_params[:user]).encrypt).increment(message)

    redirect_to message.url
  end

  private
  def deliver_params
    params.permit(:user, :message)
  end

  def authenticate
    authenticate_or_request_with_http_basic('Administration') do |username, password|
      md5_of_password = Digest::MD5.hexdigest(password)
      username == ENV['AUTH_USERNAME'] && md5_of_password == ENV['AUTH_PASSWORD']
    end
  end
end
