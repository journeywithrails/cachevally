class CreateClosures < ActiveRecord::Migration
  def self.up
    create_table :closures do |t|
      t.column :listing_id, :integer
      t.column :closed_at, :datetime
      t.column :title, :string
      t.column :description, :text
      t.column :created_on, :datetime, :null => false
      t.column :updated_on, :datetime, :null => false
    end
  end

  def self.down
    drop_table :closures
  end
end
