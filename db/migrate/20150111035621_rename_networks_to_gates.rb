class RenameNetworksToGates < ActiveRecord::Migration
  def change
    # Gate doesn't handle networks, it handles gates. (A bit silly how long
    # it took me to realize I should just call them gates)
    
    rename_table :networks, :gates
    rename_table :user_networks, :user_gates
    
    rename_column :keys, :encrypted_networks, :encrypted_gates
    rename_column :posts, :network_id, :gate_id
    rename_column :user_gates, :network_id, :gate_id
  end
end
