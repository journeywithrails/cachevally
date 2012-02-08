class AddImportInfoToListing < ActiveRecord::Migration
  def self.up
    add_column :listings, :imported_on, :datetime
  end

  def self.down
    remove_column :listings, :imported_on
  end
end
