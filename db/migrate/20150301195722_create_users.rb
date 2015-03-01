class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :url
      t.integer :status
      t.string :network

      t.timestamps
    end
  end
end
