class CreateStatuses < ActiveRecord::Migration
  def change
    # I rolled back and changed it to posts.
    # Kept class name because of some weird migration error.
    create_table :posts do |t|
      t.uuid    :external_id, null: false
      t.integer :user_id,     null: false
      t.integer :network_id,  null: false
      t.text    :body,        null: false

      t.timestamps
    end
    
    add_index :posts, :external_id, unique: true
    add_index :posts, :network_id
    add_index :posts, :user_id
  end
end
