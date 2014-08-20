class RemoveExternalIdFromKeys < ActiveRecord::Migration
  def change
    remove_column :keys, :external_id, :uuid
  end
end
