class CreateChatJob
    include Sidekiq::Job

    def perform(token, chat_number)
        Rails.logger.info("token: #{token}")
        Rails.logger.info("chat_number: #{chat_number}")
        @application = Application.find_by("token": token)
        @chat = @application.chats.new(number: chat_number)
        @application.increment!(:chats_count)
        @chat.save
        @application.with_lock do
            @application.save
        end
    end 
end