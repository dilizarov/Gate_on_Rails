class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.text :platform,   null: false
      t.text :token,      null: false
      t.integer :user_id, null: false

      t.timestamps
    end
    
    add_index :devices, :token
  end
end
