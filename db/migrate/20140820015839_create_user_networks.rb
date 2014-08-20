class CreateUserNetworks < ActiveRecord::Migration
  def change
    create_table :user_networks do |t|
      t.integer :user_id,      null: false
      t.integer :network_id,   null: false
      t.integer :gatekeeper_id
      t.boolean :anonymous,    null: false

      t.timestamps
    end
  
    add_index :user_networks, :user_id
    add_index :user_networks, :network_id
    add_index :user_networks, :gatekeeper_id
  end
end
