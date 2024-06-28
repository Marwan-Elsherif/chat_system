class CreateAppJob
    include Sidekiq::Job

    def perform(token, name)
        Rails.logger.info("token: #{token}")
        Rails.logger.info("name: #{name}")
        @application = Application.new(token: token, name: name)
        if @application.save
            Rails.logger.info("#{token}_next_chat_number: #{token}_next_chat_number")
            $redis.set("#{token}_next_chat_number", 1)
        else
            Rails.logger.error("Failed to create Application: #{application.errors.full_messages.join(", ")}")
        end
    end 
end