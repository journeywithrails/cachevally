class AddAboutToListing < ActiveRecord::Migration

  def self.up
    add_column :listings, :about, :text
    add_column :listings, :show_about, :integer
    add_column :listings, :show_hours, :integer
    add_column :listings, :show_menu, :integer
    add_column :listings, :show_images, :integer
    add_column :listings, :show_map, :integer, :default => 1
  end

  def self.down
    remove_column :listings, :about
    remove_column :listings, :show_about
    remove_column :listings, :show_hours
    remove_column :listings, :show_menu
    remove_column :listings, :show_images
    remove_column :listings, :show_map
  end

end
