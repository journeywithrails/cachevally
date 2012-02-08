class AddCaptionToItems < ActiveRecord::Migration
  def self.up
    add_column :items, :caption, :string
  end

  def self.down
    remove_column :items, :caption
  end
end
