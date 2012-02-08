class RenameCountryToCounty < ActiveRecord::Migration
  def self.up
    rename_column :listings, :country, :county
  end

  def self.down
    rename_column :listings, :county, :country
  end
end
