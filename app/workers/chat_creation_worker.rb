class ChatCreationWorker
    include Sidekiq::Worker
  
    def perform(app_token, chat_number)
      application = Application.find_by(token: app_token)
      application.chats.create!(number: chat_number)
      application.increment!(:chats_count)
    end
end