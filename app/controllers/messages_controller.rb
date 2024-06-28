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
    number = @chat.messages.maximum(:number).to_i + 1

    @chat.messages.create!(number: number, body: message_params[:body])
    @chat.increment!(:messages_count)

    render json: { message: 'Message created successfully', number: number }, status: :accepted
  end

  # Updates an existing message by its number (PATCH/PUT /messages/:number).
  def update
    if @message
      if @message.update(message_params)
        render json: @message, status: :ok
      else
        render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'Message not found' }, status: :not_found
    end
  end

  # Deletes a Message by its number (DELETE /messages/:number).
  def destroy
    if @message
      @message.destroy
      @chat.decrement!(:messages_count)
      renumber_messages(@chat)
      render json: { message: 'Message deleted successfully' }, status: :ok
    else
      render json: { error: 'Message not found' }, status: :not_found
    end
  end

  def search
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
end
