class AddListingHours < ActiveRecord::Migration
  def self.up
    add_column :listings, :mon_hours, :string
    add_column :listings, :tue_hours, :string
    add_column :listings, :wed_hours, :string
    add_column :listings, :thu_hours, :string
    add_column :listings, :fri_hours, :string
    add_column :listings, :sat_hours, :string
    add_column :listings, :sun_hours, :string
  end

  def self.down
    remove_column :listings, :mon_hours
    remove_column :listings, :tue_hours
    remove_column :listings, :wed_hours
    remove_column :listings, :thu_hours
    remove_column :listings, :fri_hours
    remove_column :listings, :sat_hours
    remove_column :listings, :sun_hours
  end
end
