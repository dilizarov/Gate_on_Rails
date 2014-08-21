class CreateStatuses < ActiveRecord::Migration
  def change
    create_table :statuses do |t|
      t.uuid    :external_id, null: false
      t.integer :user_id,     null: false
      t.integer :network_id,  null: false
      t.text    :body,        null: false

      t.timestamps
    end
    
    add_index :statuses, :external_id, unique: true
    add_index :statuses, :network_id
    add_index :statuses, :user_id
  end
end
