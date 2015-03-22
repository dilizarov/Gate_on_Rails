class AddCoordsToAuthenticationTokens < ActiveRecord::Migration
  def change
    add_column :authentication_tokens, :latitude, :decimal, precision: 9, scale: 6
    add_index :authentication_tokens, :latitude
    add_column :authentication_tokens, :longitude, :decimal, precision: 9, scale: 6
    add_index :authentication_tokens, :longitude
  end
end
