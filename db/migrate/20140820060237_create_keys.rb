class CreateKeys < ActiveRecord::Migration
  def change
    create_table :keys do |t|
      t.string  :encrypted_key,      null: false
      t.integer :gatekeeper_id,      null: false
      t.text    :encrypted_networks, null: false
      t.uuid    :external_id,        null: false

      t.timestamps
    end
  
    add_index :keys, :encrypted_key, unique: true
    add_index :keys, :external_id,   unique: true
    add_index :keys, :gatekeeper_id
  end
end
