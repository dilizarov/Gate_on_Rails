class CreateKeys < ActiveRecord::Migration
  def change
    create_table :keys do |t|
      t.string  :encrypted_key,      null: false
      t.integer :gatekeeper_id,      null: false
      t.text    :encrypted_networks, null: false
      t.integer :number_of_uses,     null: false, default: 1
      t.uuid    :external_id,        null: false

      t.timestamps
    end
  end
  
  add_index :keys, :encrypted_key, unique: true
  add_index :keys, :gatekeeper_id
end
