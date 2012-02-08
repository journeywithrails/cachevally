class CreateHits < ActiveRecord::Migration

  def self.up
    create_table :hits do |t|
      # t.column :name, :string
      t.column :listing_id, :integer
      t.column :visitor_id, :integer
      t.column :url, :string
      t.column :created_at, :datetime, :null => false
    end
  end

  def self.down
    drop_table :hits
  end
end
