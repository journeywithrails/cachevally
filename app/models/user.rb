require 'digest/sha2'
class User < ActiveRecord::Base

  # Relationships
  has_many :listings
  has_many :comments

  attr_accessor :password
  attr_accessor :password_confirmation

  # Validations
  validates_uniqueness_of   :username, :on => :create
  validates_confirmation_of :password, :on => :create
  # validates_presence_of     :email
  validates_uniqueness_of   :email, :on => :create
  validates_format_of       :email,
                            :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
                            :message => 'must be valid address'
  validates_length_of       :username, :within => 3..20
  validates_length_of       :password, :within => 5..20
  validates_presence_of     :username, :password, :password_confirmation, :name, :email

  def before_create
    salt = [Array.new(6){rand(256).chr}.join].pack("m" ).chomp
    self.password_salt, self.password_hash =
        salt, Digest::SHA256.hexdigest(self.password + salt)
  end

  def before_destroy
    # check if this person was the editor for a listing
    @listing = Listing.find_by_user_id(self.id)
    if @listing
      @listing.update_attribute('user_id', 0)
    end
  end

#  def password=(pass)
#    salt = [Array.new(6){rand(256).chr}.join].pack("m" ).chomp
#    self.password_salt, self.password_hash =
#        salt, Digest::SHA256.hexdigest(pass + salt)
#  end
  
end
