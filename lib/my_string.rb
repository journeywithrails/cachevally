class String
  
  # Check if a string is numeric
  def is_numeric?
    # self =~ Regex.new('\D')
    self =~ /\D/
  end

end