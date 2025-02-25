class CreateApplications < ActiveRecord::Migration[7.2]
  def change
    create_table :applications do |t|
      t.string :token
      t.string :name, null: false, index: true
      t.integer :chats_count, default: 0

      t.timestamps
    end
  end
end
