class CreateNetworks < ActiveRecord::Migration
  def change
    create_table :networks do |t|
      t.string  :name,        null: false
      t.integer :creator_id,  null: false
      t.uuid    :external_id, null: false

      t.timestamps
    end
    
    add_index :networks, :creator_id
    add_index :networks, :external_id, unique: true
  end
end
