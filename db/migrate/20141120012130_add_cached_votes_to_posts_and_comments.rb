class AddCachedVotesToPostsAndComments < ActiveRecord::Migration
  def change
    add_column :posts,    :cached_votes_up, :integer, default: 0
    add_column :comments, :cached_votes_up, :integer, default: 0
    
    add_index :posts,    :cached_votes_up
    add_index :comments, :cached_votes_up
  end
end
