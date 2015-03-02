class AddUniquenessToUserGateAssociation < ActiveRecord::Migration
  def change
    add_index :user_gates, [:user_id, :gate_id], unique: true
  end
end
