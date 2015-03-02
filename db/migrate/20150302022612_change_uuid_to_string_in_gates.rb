class ChangeUuidToStringInGates < ActiveRecord::Migration
  def up
    change_column :gates, :external_id, :text
  end
  
  def down
    change_column :gates, :external_id, :uuid
  end
end
