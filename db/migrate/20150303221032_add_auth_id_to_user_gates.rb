class AddAuthIdToUserGates < ActiveRecord::Migration
  def change
    add_column :user_gates, :auth_token_id, :integer
    add_index :user_gates, :auth_token_id
  end
end
