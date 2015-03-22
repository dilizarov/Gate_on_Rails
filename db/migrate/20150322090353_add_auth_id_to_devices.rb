class AddAuthIdToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :auth_id, :integer
    add_index :devices, :auth_id
  end
end
