class Message < ApplicationRecord
  belongs_to :chat
  validates_presence_of :body
  searchkick 
end
