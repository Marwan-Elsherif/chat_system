class CreateMessageJob
    include Sidekiq::Job

    def perform(token, chat_num, msg_num, body)
        Rails.logger.info("token: #{token}")
        Rails.logger.info("chat_num: #{chat_num}")

        Rails.logger.info("msg_num: #{msg_num}")
        Rails.logger.info("body: #{body}")

        @application = Application.find_by("token": token)
        @chat = @application.chats.find_by("number": chat_num)
        @message = @chat.messages.new(number: msg_num, body: body)
        @chat.with_lock do
            @chat.increment!(:messages_count)
            @chat.save
        end
        @message.save
    end 
end