class AddImgUrlsToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :img_urls, :text
  end
end
