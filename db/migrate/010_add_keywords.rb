class AddKeywords < ActiveRecord::Migration
  def self.up
    add_column :listings, :keywords, :string
  end

  def self.down
    remove_column :listings, :keywords
  end
end
