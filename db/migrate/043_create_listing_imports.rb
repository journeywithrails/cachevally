class CreateListingImports < ActiveRecord::Migration
  def self.up
    create_table :create_listing_imports do |t|
      t.column :business, :string, :null => false
      # t.column :tagline, :string
      t.column :address, :string
      # t.column :address2, :string
      # t.column :city, :string
      # t.column :state, :string
      # t.column :zip, :string
      # t.column :country, :string
      # t.column :email, :string
      # t.column :website, :string
      t.column :phone, :string
      # t.column :fax, :string
      # t.column :phone2, :string
      # t.column :image, :string
      # t.column :active, :integer, :default => 0
      # t.column :created_on, :datetime, :null => false, :default => '0000-00-00 00:00:00'
      # t.column :updated_on, :datetime, :null => false, :default => '0000-00-00 00:00:00'
    end
  end

  def self.down
    drop_table :create_listing_imports
  end
end
