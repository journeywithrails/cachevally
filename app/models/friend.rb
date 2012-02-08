class Friend < ActiveRecord::Base

  # Validation
  validates_presence_of :name, :email, :sender_name, :sender_email
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  validates_format_of :sender_email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i

end
