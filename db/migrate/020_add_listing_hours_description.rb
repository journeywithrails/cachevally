class AddListingHoursDescription < ActiveRecord::Migration
  def self.up
    add_column :listings, :hours_description, :string
  end

  def self.down
    remove_column :listings, :hours_description
  end
end
