class AddAccountSubscription < ActiveRecord::Migration
  def self.up
    add_column :users, :subscribed, :string, :default => 0
    add_column :users, :subscription_date, :datetime
    add_column :users, :subscription_ip, :string
  end

  def self.down
    remove_column :users, :subscribed
    remove_column :users, :subscription_date
    remove_column :users, :subscription_ip  
  end
end
