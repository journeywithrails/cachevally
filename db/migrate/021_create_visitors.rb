class CreateVisitors < ActiveRecord::Migration

  def self.up
    create_table :visitors do |t|
      # t.column :name, :string
      t.column :ip, :string
      t.column :created_at, :datetime, :null => false
      t.column :updated_at, :datetime, :null => false
    end
  end

  def self.down
    drop_table :visitors
  end
end
