class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column "listing_id", :integer
      t.column "username", :string
      t.column "password_salt", :string
      t.column "password_hash", :string
      t.column "name", :string
      t.column "email", :string
      t.column "is_active", :integer
      t.column "is_admin", :integer
      t.column "updated_on", :timestamp
      t.column "created_on", :timestamp
      t.column "login_on", :timestamp
    end
  end

  def self.down
    drop_table :users
  end
end
