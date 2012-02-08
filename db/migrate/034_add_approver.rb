class AddApprover < ActiveRecord::Migration
  def self.up
    add_column :listings, :approver_id, :integer
    add_column :listings, :approved_on, :datetime
  end

  def self.down
    remove_column :listings, :approver_id
    remove_column :listings, :approved_on
  end
end
