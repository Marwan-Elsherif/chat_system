class UpdateMessageJob
    include Sidekiq::Job

    def perform(token, chat_num, msg_num, body)
        Rails.logger.info("token: #{token}")
        Rails.logger.info("chat_num: #{chat_num}")

        Rails.logger.info("msg_num: #{msg_num}")
        Rails.logger.info("body: #{body}")

        @application = Application.find_by("token": token)
        @chat = @application.chats.find_by("number": chat_num)
        @message = @chat.messages.find_by(number: msg_num)
        @message.with_lock do
            if @message.update(body: body)
                Rails.logger.info("Message #{msg_num} is updated successfully with new content #{body}")
            else
                Rails.logger.error("Failed to update message: #{msg_num}")
            end
        end
    end 
end