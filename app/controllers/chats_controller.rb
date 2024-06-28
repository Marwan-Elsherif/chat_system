class ChatsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  before_action :find_application_by_token
  before_action :find_chat_by_number, only: [:show, :destroy]
  
  # Retrieves a list of all chats (GET /chats).
  def index
    @chats = @application.chats
    render json: @chats.as_json, status: :ok
  end

  # Retrieves a single application by its token (GET /chats/:number).
  def show
    if @chat
      render json: @chat, status: :ok
    else
      render json: { error: 'Chat not found' }, status: :not_found
    end
  end

  # Creates a new chat (POST /chats).
  def create
    chat_number = get_chat_number
    Rails.logger.info("params: #{params}")
    Rails.logger.info("params[:token]: #{params[:token]}")
    Rails.logger.info("params[:application_token]: #{params[:application_token]}")
    $redis.set("#{params[:application_token]}_#{chat_number}_message_number", 1)
    token = params[:application_token]
    CreateChatJob.perform_async(token, chat_number)
    render json: {number: chat_number, messages_count: 0}, status: :created
  end

  # Deletes a chat by its token (DELETE /chats/:number).
  def destroy    
    if @chat
      @chat.with_lock do
        @chat.destroy!
      end
      @application.with_lock do
        @application.decrement!(:chats_count)
      end
      renumber_chats(@application)
      decrement_chat_number
      render json: { message: "Chat #{@chat.number} deleted successfully" }, status: :ok
    else
      render json: { error: 'Chat not found' }, status: :not_found
    end
  end

  private

    def find_application_by_token
      @application = Application.find_by(token: params[:application_token])
    end

    def find_chat_by_number
      @chat = @application.chats.find_by(number: params[:number]) if @application
    end

    def record_not_found
      render json: { error: 'Chat not found' }, status: :not_found
    end

    def get_chat_number
      Rails.logger.info("params[:application_token]: #{params[:application_token]}")
      $redis_lock.lock("#{params[:application_token]}_chat_number", 5000) do |locked|
        output = $redis.get("#{params[:application_token]}_chat_number")
        $redis.set("#{params[:application_token]}_chat_number", output.to_i + 1)
        return output
      end
    end

    def decrement_chat_number
      $redis_lock.lock("#{params[:application_token]}_chat_number", 5000) do |locked|
        current_number = $redis.get("#{params[:application_token]}_chat_number").to_i
        $redis.set("#{params[:application_token]}_chat_number", current_number - 1)
      end
    end

    def renumber_chats(application)
      application.chats.order(:number).each_with_index do |chat, index|
        chat.update_column(:number, index + 1)
      end  
    end
end
