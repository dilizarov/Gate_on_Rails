class AddImageIdToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :image_id, :uuid
    add_index :posts, :image_id, unique: true
  end
end
