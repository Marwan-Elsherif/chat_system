class ChatsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  before_action :find_application_by_token, only: %i[ index show destroy ]
  before_action :find_chat_by_number, only: %i[ show destroy ]
  
  # Retrieves a list of all chats (GET /chats).
  def index
    @chats = @application.chats
    render json: @chats.as_json, status: :ok
  end

  # Creates a new chat (POST /chats).
  def create
    application = Application.find_by(token: params[:application_token])
    number = application.chats.maximum(:number).to_i + 1

    application.chats.create!(number: number)
    application.increment!(:chats_count)
    render json: { message: 'Chat creation in process' }, status: :accepted
  end

  # Retrieves a single application by its token (GET /chats/:number).
  def show
    if @chat
      render json: @chat, status: :ok
    else
      render json: { error: 'Chat not found' }, status: :not_found
    end
  end

  # Deletes an application by its token (DELETE /chats/:number).
  def destroy
    if @chat
      chat_number = @chat.number
      @chat.destroy
      render json: { message: "Chat #{chat_number} deleted successfully" }, status: :ok
    else
      render json: { error: 'Chat not found' }, status: :not_found
    end
  end

  private
    def chat_params
      params.require(:chat).permit(:number)
    end

    def find_application_by_token
      @application = Application.find_by(token: params[:application_token])
    end

    def find_chat_by_number
      @chat = @application.chats.find_by(number: params[:number]) if @application
    end

    def record_not_found
      render json: { error: 'Chat not found' }, status: :not_found
    end
end
