class DashboardController < ApplicationController
  def index
    @accounts = Account.all
    @messages = Message.all
    @activate = VkontakteApi.authorization_url(type: :client, scope: [:friends, :messages, :wall, :offline])
  end

  def vk_authorize
    begin
      account = Account.find(vk_params[:user_id])
      uri = URI.parse(vk_params[:user_url])
      cgi = CGI::parse(uri.fragment)

      if account.update(access_token: cgi['access_token'][0], uid: cgi['user_id'][0])
        redirect_to root_path, notice: 'Account successfully activated!'
      else
        redirect_to root_path, alert: 'Something went wrong... try to find out what in the log file'
      end
    rescue
      redirect_to root_path, alert: 'You passed not all needed parametrs. Please, try again and do it gentle)'
    end
  end

  private
  def vk_params
    params.permit(:user_id, :user_url)
  end
end
