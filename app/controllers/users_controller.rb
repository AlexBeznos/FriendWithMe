require 'configatron'

class UsersController < ActionController::Base
  protect_from_forgery with: :exception
  before_filter :authenticate, except: :redirect
  layout 'paper'

  def index
    @users = User.paginate(:page => params[:page], :per_page => 10)
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to users_path, notice: 'User created successfully!'
    else
      redirect_to users_path, alert: 'Something went wrong...'
    end
  end

  def start_sending
    if User.any? && Account.active.any? && Message.active.any?
      configatron.aproved = true
      redirect_to users_path, notice: 'Messages sending had been started!'
    else
      redirect_to users_path, alert: "I'm not gona start sending until everything will be ready! Now you have #{User.all.count} users, #{Account.active.count} active accounts and #{Message.active.count} active messages."
    end
  end

  def redirect
    message = Message.find(SecureId.new(deliver_params[:message]).decrypt.to_i)
    User.find(SecureId.new(deliver_params[:account]).decrypt.to_i).increment_message_relation(message)

    redirect_to message.url
  end

  def destroy
    @user = User.find(params[:id])

    if @user.destroy
      redirect_to users_path, notice: 'User successfully destroyied'
    else
      redirect_to users_path, alert: 'Something went wrong...'
    end
  end

  private
  def deliver_params
    params.permit(:account, :message)
  end

  def user_params
    params.require(:user).permit(:url)
  end

  def authenticate
    authenticate_or_request_with_http_basic('Administration') do |username, password|
      md5_of_password = Digest::MD5.hexdigest(password)
      username == ENV['AUTH_USERNAME'] && md5_of_password == ENV['AUTH_PASSWORD']
    end
  end
end
