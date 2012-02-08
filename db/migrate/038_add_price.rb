class AddPrice < ActiveRecord::Migration
  def self.up
    add_column :specials, :cost, :decimal, {:scale => 2, :precision => 5} 
    # Special.find(:all).each do |special|
    #   special.update_attribute('cost', special.price) unless special.price_in_cents.nil?
    # end
    # remove_column :specials, :price_in_cents
  end

  def self.down
    add_column :specials, :price_in_cents, :integer # dollars_and_cents plugin
    # Special.find(:all).each do |special|
    #   special.update_attribute('price', special.cost) unless special.cost.nil?
    # end
    # remove_column :specials, :cost
  end
end
