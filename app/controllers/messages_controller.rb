class MessagesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  before_action :find_application_by_token
  before_action :find_chat_by_number
  before_action :find_message_by_number, only: [ :show, :create, :destroy, :update ]
  before_action :message_params, only: [ :update ]

  # Retrieves a list of all messages (GET /messages).
  def index
    @messages = @chat.messages
    render json: @messages.as_json, status: :ok
  end

  # Retrieves a single message by its number (GET /message/:number).
  def show
    if @message
      render json: @message, status: :ok
    else
      render json: { error: 'Message not found' }, status: :not_found
    end
  end

  # Creates a new message (POST /messages).
  def create
    msg_num = get_msg_number
    Rails.logger.info("params: #{params}")
    Rails.logger.info("#{params[:application_token]}_#{params[:chat_number]}_message_number: #{params[:application_token]}_#{params[:chat_number]}_message_number")
    CreateMessageJob.perform_async(params[:application_token], params[:chat_number], msg_num, params[:body])
    render json: {number: msg_num, message: params[:message]}, status: :created
  end

  # Updates an existing message by its number (PATCH/PUT /messages/:number).
  def update
    if @message
      Rails.logger.info("params: #{params}")
      UpdateMessageJob.perform_async(params[:application_token], params[:chat_number], params[:number], params[:body])
      render json: {number: params[:number]}, status: :ok
    else
      render json: { error: 'Message not found' }, status: :not_found
    end
  end

  # Deletes a Message by its number (DELETE /messages/:number).
  def destroy
    if @message
      @message.with_lock do
        @message.destroy!
      end
      @chat.with_lock do
        @chat.decrement!(:messages_count)
      end
      renumber_messages(@chat)
      decrement_msg_number
      render json: { message: 'Message deleted successfully' }, status: :ok
    else
      render json: { error: 'Message not found' }, status: :not_found
    end
  end

  def search
    Rails.logger.info("params[:message]: #{params[:message]}")
    @result = Message.search(params[:message])
    render json: @result, status: :ok
  end

  private

    def find_application_by_token
      @application = Application.find_by(token: params[:application_token])
    end

    def find_chat_by_number
      @chat = @application.chats.find_by(number: params[:chat_number]) if @application
    end

    def find_message_by_number
      @message = @chat.messages.find_by("number": params[:number]) if @chat
    end

    def message_params
      params.require(:message).permit(:body)
    end

    def record_not_found
      render json: { error: 'Chat not found' }, status: :not_found
    end

    def renumber_messages(chat)
      chat.messages.order(:number).each_with_index do |message, index|
        message.update_column(:number, index + 1)
      end  
    end

    def get_msg_number
      Rails.logger.info("#{params[:application_token]}_#{params[:chat_number]}_message_number: #{params[:application_token]}_#{params[:chat_number]}_message_number")
      $redis_lock.lock("#{params[:application_token]}_#{params[:chat_number]}_message_number", 5000) do |locked|
        output = $redis.get("#{params[:application_token]}_#{params[:chat_number]}_message_number")
        Rails.logger.info("output: #{output}")

        $redis.set("#{params[:application_token]}_#{params[:chat_number]}_message_number", output.to_i + 1)
        Rails.logger.info("output.to_i + 1: #{output.to_i + 1}")
        return output
      end
    end

    def decrement_msg_number
      $redis_lock.lock("#{params[:application_token]}_#{params[:chat_number]}_message_number", 5000) do |locked|
        current_number = $redis.get("#{params[:application_token]}_#{params[:chat_number]}_message_number").to_i
        $redis.set("#{params[:application_token]}_#{params[:chat_number]}_message_number", current_number - 1)
      end
    end
end
