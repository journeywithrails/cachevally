# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base

  # include ExceptionNotifiable

  def check_authentication
    if session[:user] # and authorize?(session[:user])
      return true
    end
    # call overwriteable reaction to unauthorized access
    access_denied
    return false 
  end
  
  def access_denied
    respond_to do |accepts|  
      accepts.html do  
        flash[:notice] = 'Please login to access this resource.'
        store_location  
        redirect_to :controller => '/account', :action => 'login'  
      end  
      accepts.js do  
        render(:update) { |page| page.redirect_to(:controller => '/account', :action => 'login') }  
      end  
      accepts.xml do  
        headers["Status"]           = "Unauthorized"  
        headers["WWW-Authenticate"] = %(Basic realm="Web Password")  
        render :text => "Could't authenticate you", :status => '401 Unauthorized'  
      end  
    end  
    false
  end

  # store current uri in  the session.
  # we can return to this location by calling return_location
  def store_location
    # session[:intended_action] = action_name
    # session[:intended_controller] = controller_name
    # session[:intended_id] = params[:id]
    session[:return_to] = request.request_uri
  end


  # def check_authentication
  #   unless session[:user]
  #     session[:intended_action] = action_name
  #     session[:intended_controller] = controller_name
  #     session[:intended_id] = params[:id]
  #     flash[:notice] = 'Please login to access this resource.'
  #     redirect_to :controller => '/account', :action => 'login'
  #   end
  # end

  def check_admin_authentication
    if session[:user] and is_admin?
      return true
    end
    # call overwriteable reaction to unauthorized access
    access_denied
    return false 
    # unless session[:user] and is_admin?
    #   session[:intended_action] = action_name
    #   session[:intended_controller] = '/admin/' + controller_name
    #   session[:intended_id] = params[:id]
    #   flash[:error] = 'You must be logged in as an administrator to access this resource.'
    #   redirect_to :controller => '/account', :action => 'login'
    # end
  end

  def check_has_paid_listing?
    return true if is_admin?
    return false if !user_logged_in?
    @user = session[:user]
    return false if @user.nil?
    # date_paid_start
    # date_paid_expires
    @paid_listing = Listing.find(:first, :conditions => ["user_id = ? and editor_approved = ? and date_paid_start <= ? and date_paid_expires > ?", @user, 1, Date.today, Date.today ])
    if @paid_listing
      return true
    else
      return false
    end
  end

  # If the session variable 'user' exists, the user must be logged in.
  def user_logged_in?
    session[:user]
  end
  helper_method :user_logged_in?

  def is_hjnews?
    # return true if ENV['RAILS_ENV'] == 'development'
    if request.server_name == 'hjnews.cachevalleysearch.com'
      return true
    elsif request.server_name == 'www.hjnews.cachevalleysearch.com'
      return true
    else
      return false
    end
  end
  helper_method :is_hjnews?
  
  def is_kuta8?
    # return true if ENV['RAILS_ENV'] == 'development'
    if request.server_name == 'kuta8.cachevalleysearch.com'
      return true
    else
      return false
    end
  end
  helper_method :is_kuta8?
  
  # If the session contains the login key that equals the configured admin account
  def is_admin?
    @user = User.find(session[:user])
    @user.is_admin?
#    @session[:user]
#    @session[:is_admin]
  end
  helper_method :is_admin?

  def is_owner_or_admin?(listing)
    return false unless user_logged_in?
    return true if is_admin?
    return true if listing.user_id == @user.id and listing.editor_approved?
  end
  helper_method :is_owner_or_admin?

  # def blank?
  #   if self == nil or self.empty
  #     return true
  #   else
  #     return false
  #   end
  # end

  def get_salt
    [Array.new(6){rand(256).chr}.join].pack("m" ).chomp
  end
  
  def make_hash(password, salt)
    Digest::SHA256.hexdigest(password + salt)
  end

#  protected :checkCaptcha

  def checkCaptcha
    # returns true/false depending on valid captcha code input.
    # on true, destroys the captcha.  on too many false tries,
    # the captcha is also destroyed.
  
    # load the captcha
#    captchaId = @params['captcha_id'].to_s.trim.to_i
    captchaId = @params['captcha_id']
    code = @params['captcha_code'].to_i
#    code = @params['captcha_code'].to_s.trim.to_i
    begin
      captcha = Captcha.find(captchaId)
    rescue
      return false
    end
  
    # check code
    if code==captcha.code
      # can't be used again once it's been successful
      captcha.destroy
      return true
    else
      captcha.failures = captcha.failures + 1
      if captcha.failures >= 10:
        # destroyed on tenth failure to prevent brute force guessing on
        # the same captcha, but still allows humans to fail and try again.
        captcha.destroy
      else
        captcha.save
      end
      return false
    end
  end

  def random_string(size = 15)
    s = String.new
    size.times do |i|
      # s << (Kernel.rand(93)+33)   # full ascii range
      s << (Kernel.rand(26)+97)   # ascii lowercase only
    end
    s
  end

  def redirect_back_or_default(default = {:controller => "/listings", :action => "index"})
    if session[:return_to].nil?
      redirect_to default
    else
      redirect_to session[:return_to]
      session[:return_to] = nil
    end
    # if @session[:return].nil?
    #   redirect_to default
    # else
    #   redirect_to_url @session[:return]
    #   session[:return] = nil
    # end
  end

end