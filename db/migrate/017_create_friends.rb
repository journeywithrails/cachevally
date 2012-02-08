class CreateFriends < ActiveRecord::Migration
  def self.up
    create_table :friends do |t|
      # t.column :name, :string
      t.column :name, :string
      t.column :email, :string
      t.column :sender_name, :string
      t.column :sender_email, :string
      t.column :created_on, :datetime, :null => false, :default => '0000-00-00 00:00:00'
    end
  end

  def self.down
    drop_table :friends
  end
end
