class AddServicesTab < ActiveRecord::Migration
  def self.up
    add_column :listings, :services, :text
    add_column :listings, :show_services, :integer, :default => 0
  end

  def self.down
    remove_column :listings, :services
    remove_column :listings, :show_services
  end
end
