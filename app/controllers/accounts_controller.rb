class AccountsController < ApplicationController
  before_action :set_account, only: [:show, :edit, :update, :destroy]

  # GET /accounts/1
  # GET /accounts/1.json
  def show
  end

  # POST /accounts
  # POST /accounts.json
  def create
    @account = Account.new(account_params)

    if @account.save
      redirect_to root_path, notice: 'Account was successfully created.'
    else
      redirect_to root_path, alert: 'Some thing went wrong! try more...'
    end
  end

  def edit
  end

  # PATCH/PUT /accounts/1
  # PATCH/PUT /accounts/1.json
  def update
    if @account.update(account_params)
      redirect_to root_path, notice: 'Account was successfully updates.'
    else
      redirect_to root_path, alert: 'Some thing went wrong! try more...'
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.json
  def destroy
    @account.destroy
    redirect_to root_path, notice: 'Account was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def account_params
      params.require(:account).permit(:email, :status, :uid, :access_token)
    end
end
