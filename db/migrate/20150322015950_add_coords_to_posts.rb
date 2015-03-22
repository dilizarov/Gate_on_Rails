class AddCoordsToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :latitude, :decimal, precision: 9, scale: 6
    add_index :posts, :latitude
    add_column :posts, :longitude, :decimal, precision: 9, scale: 6
    add_index :posts, :longitude
  end
end
