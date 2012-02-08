class AddPriceToSpecials < ActiveRecord::Migration
  def self.up
    add_column :specials, :price, :string
    Special.find(:all).each do |special|
      special.update_attribute('price', special.cost.to_s)
    end
    remove_column :specials, :cost
  end

  def self.down
    remove_column :specials, :price
    Special.find(:all).each do |special|
      special.update_attribute('cost', value_to_decimal(special.price))
    end
    add_column :specials, :cost, :decimal, {:scale => 2, :precision => 5} 
  end
end
