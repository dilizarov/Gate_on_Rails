class AddGeneratedToGate < ActiveRecord::Migration
  def change
    add_column :gates, :generated, :boolean, default: false
  end
end
