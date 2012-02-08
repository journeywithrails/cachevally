class ModifyListingImport < ActiveRecord::Migration

  def self.up
    add_column :listing_imports, :listing_id, :integer
    add_column :listing_imports, :address2, :string
    add_column :listing_imports, :city, :string
    add_column :listing_imports, :state, :string
    add_column :listing_imports, :country, :string
    add_column :listing_imports, :email, :string
    add_column :listing_imports, :website, :string
    add_column :listing_imports, :phone2, :string
    add_column :listing_imports, :fax, :string
  end

  def self.down
    remove_column :listing_imports, :listing_id
    remove_column :listing_imports, :address2
    remove_column :listing_imports, :city
    remove_column :listing_imports, :state
    remove_column :listing_imports, :country
    remove_column :listing_imports, :email
    remove_column :listing_imports, :website
    remove_column :listing_imports, :phone2
    remove_column :listing_imports, :fax
  end

end
