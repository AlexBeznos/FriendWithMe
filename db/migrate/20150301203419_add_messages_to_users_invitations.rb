class AddMessagesToUsersInvitations < ActiveRecord::Migration
  def change
    add_column :users, :messages, :text
  end
end
