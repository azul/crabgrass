class AddWidgetIdToSite < ActiveRecord::Migration
  def self.up
    add_column :sites, :widget_id, :integer
  end

  def self.down
    remove_column :sites, :widget_id
  end
end
