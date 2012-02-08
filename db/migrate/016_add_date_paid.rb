class AddDatePaid < ActiveRecord::Migration

  def self.up
    add_column :listings, :date_paid_start, :datetime
    add_column :listings, :date_paid_expires, :datetime
  end

  def self.down
    remove_column :listings, :date_paid_start
    remove_column :listings, :date_paid_expires
  end

end
