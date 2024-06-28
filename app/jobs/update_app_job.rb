class UpdateAppJob
    include Sidekiq::Job

    def perform(token, name)
        Rails.logger.info("token: #{token}")
        @application = Application.find_by("token": token)
        @application.with_lock do
            if @application.update(name: name)
                Rails.logger.info("App #{name} is updated successfully")
            else
                Rails.logger.error("Failed to update app: #{name}")
            end
        end
    end 
end