class AddStatColumns < ActiveRecord::Migration
  def self.up
    add_column :hits, :controller, :string
    add_column :hits, :action, :string
    add_column :hits, :subaction, :string
  end

  def self.down
    remove_column :hits, :controller
    remove_column :hits, :action
    remove_column :hits, :subaction
  end
end
