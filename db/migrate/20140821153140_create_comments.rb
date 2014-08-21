class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.uuid    :external_id, null: false
      t.integer :user_id,     null: false
      t.integer :post_id,     null: false
      t.text    :body,        null: false

      t.timestamps
    end
    
    add_index :comments, :external_id, unique: true
    add_index :comments, :user_id
    add_index :comments, :post_id
  end
end
