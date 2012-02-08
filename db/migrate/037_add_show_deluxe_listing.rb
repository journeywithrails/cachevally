class AddShowDeluxeListing < ActiveRecord::Migration
  def self.up
    add_column :listings, :show_deluxe, :integer, :default => 0
  end

  def self.down
    remove_column :listings, :show_deluxe
  end
end
