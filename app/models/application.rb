class Application < ApplicationRecord
    has_many :chats, dependent: :destroy
    validates_presence_of :name


    def chats_count
        self.chats.count
    end
end
