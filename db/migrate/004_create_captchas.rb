class CreateCaptchas < ActiveRecord::Migration
  def self.up
    create_table :captchas do |t|
      t.column :code, :integer, :null => false, :default => 0
      t.column :created_on, :datetime, :null => false, :default => '0000-00-00 00:00:00'
      t.column :failures, :integer, :null => false, :default => 0
    end
  end

  def self.down
    drop_table :captchas
  end
end
