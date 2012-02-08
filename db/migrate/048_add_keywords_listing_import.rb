class AddKeywordsListingImport < ActiveRecord::Migration
  def self.up
    add_column :listing_imports, :keywords, :string
  end

  def self.down
    add_column :listing_imports, :keywords
  end
end
