class CreateAssets < ActiveRecord::Migration

  def self.up
    create_table :assets do |t|
      t.column :listing_id, :integer
      t.column :image,      :string
      t.column :asset_type, :string
      t.column :name,       :string
      t.column :caption,    :string
      t.column :created_on, :datetime, :null => false, :default => '0000-00-00 00:00:00'
      t.column :updated_on, :datetime, :null => false, :default => '0000-00-00 00:00:00'
    end
  end

  def self.down
    drop_table :assets
  end

end
