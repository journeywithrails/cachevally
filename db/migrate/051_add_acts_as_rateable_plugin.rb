class AddActsAsRateablePlugin < ActiveRecord::Migration
  def self.up
    create_table :ratings, :force => true do |t|  
      t.column :rating,        :integer,  :default => 0  
      t.column :rateable_type, :string,   :default => "", :null => false, :limit => 15
      t.column :rateable_id,   :integer,  :default => 0,  :null => false  
      t.column :user_id,       :integer,  :default => 0,  :null => false  
      t.column :created_at,    :datetime,                 :null => false  
    end  
    
    add_index "ratings", ["user_id"], :name => "fk_ratings_user"
  end

  def self.down
    drop_table :ratings
  end
end
