class UsersController
  before_filter :authenticate, except: :redirect

  def start_sendind
    User.send_message
    redirect_to root_path, notice: 'Sending started'
  end


  def redirect
    UsersInvitations.increment({:user_id => deliver_params[:user],
                                :message_id => deliver_params[:message]})

    url = Message.find(SecureId.new(deliver_params[:message]).decrypt).url
    redirect_to url
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
