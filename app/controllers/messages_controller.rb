class MessagesController < ApplicationController
  before_action :set_message, only: [:show, :edit, :update, :destroy]
  after_action :check_attachments, only: [:create, :update]

  # GET /messages/1
  # GET /messages/1.json
  def show
  end

  # POST /messages
  # POST /messages.json
  def create
    @message = Message.new(message_params)

    if @message.save
      redirect_to root_path, notice: 'Message was successfully created. Attachments starts to download...'
    else
      redirect_to root_path, alert: 'Some thing went wrong! try more...'
    end
  end

  def edit
  end

  def status
    @message = Message.find(params[:message_id])

    if @message.change_status
      redirect_to root_path, notice: 'Message status was successfully changed.'
    else
      redirect_to root_path, alert: 'Some thing went wrong! try more...'
    end
  end

  # PATCH/PUT /messages/1
  # PATCH/PUT /messages/1.json
  def update
    if @message.update(message_params)
      redirect_to root_path, notice: 'Message was successfully updates. Attachments starts to download...'
    else
      redirect_to root_path, alert: 'Some thing went wrong! try more...'
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    if @message.destroy
      redirect_to root_path, notice: 'Message was successfully destroyed.'
    else
      redirect_to root_path, alert: 'Some thing went wrong! try more...'
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
      params.require(:message).permit(:body, :attachment, :url)
    end

    def check_attachments
      @message.retrive_attachments
    end
end
