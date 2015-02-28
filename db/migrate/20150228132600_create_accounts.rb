class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :email
      t.integer :status
      t.string :uid
      t.string :access_token

      t.timestamps
    end
  end
end
