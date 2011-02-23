class CreateWidgets < ActiveRecord::Migration
  def self.up
    create_table :widgets do |t|
      t.string :type
      t.integer :parent_id
      t.integer :position
      t.string :label

      t.timestamps
    end
  end

  def self.down
    drop_table :widgets
  end
end
