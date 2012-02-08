class CreateSpecials < ActiveRecord::Migration
  def self.up
    create_table :specials do |t|
      t.column :listing_id,     :integer
      t.column :title,          :string
      t.column :price_in_cents, :integer # dollars_and_cents plugin
      t.column :image,          :string
      t.column :description,    :text
      t.column :special_type,   :string
      t.column :date_active,    :date
      t.column :date_expires,   :date
      t.column :updated_on,     :timestamp
      t.column :created_on,     :timestamp
    end
    add_column :listings, :show_specials, :integer, :default => 0
  end

  def self.down
    drop_table :specials
    remove_column :listings, :show_specials
  end
end
