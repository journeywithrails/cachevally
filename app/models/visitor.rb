class Visitor < ActiveRecord::Base

  has_many :hits

  def self.create_if_new_today(ip)
    if ip.nil?
      return Visitor.new
    else
      @visitor = Visitor.find( :first,
                               :conditions => [ "ip = ? and updated_at >= ?", ip, Date.today() ] )
      return @visitor ||= Visitor.new
    end
  end

end
