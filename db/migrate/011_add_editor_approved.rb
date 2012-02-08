class AddEditorApproved < ActiveRecord::Migration
  def self.up
    add_column :listings, :editor_approved, :integer, :default => 0 
  end

  def self.down
    remove_column :listings, :editor_approved
  end
end
