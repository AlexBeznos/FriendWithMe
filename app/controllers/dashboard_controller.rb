class DashboardController < ApplicationController
  def index
    @accounts = Account.all
    @messages = Message.all
  end
end
