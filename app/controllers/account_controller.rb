require 'digest/sha2'
class AccountController < ApplicationController

  in_place_edit_for :user, :email
  in_place_edit_for :user, :name

  layout 'default'

  before_filter :check_authentication, :except => [ :login, :signup, :register, :reset_password, :forgot_password, :tell_a_friend, :upgrade_now ]
  # before_filter :check_has_paid_listing?, :only => [ :resources ]

  def index
    # view account settings
    @has_paid_listing = check_has_paid_listing?
    @user = User.find(session[:user])
    @listings = Listing.find :all,
                             :conditions => [ "user_id = ?", session[:user] ]
#    @listing = Listing.find_by_user_id(session[:user])
    render :action => "account/index", :layout => "default"
  end

  def login
    @page_title = "Login"
    if request.post?
      user = User.find(:first, :conditions => ['username = ?' , params[:username]])
      if user.blank? || Digest::SHA256.hexdigest(params[:password] + user.password_salt) != user.password_hash
        flash[:error] = 'Username or password invalid.'
#      elsif !user.is_active?
#        flash[:error] = 'Sorry, your account has not yet been activated. Please try again later.'
      else
        session[:user] = user.id
        session[:is_admin] = user.is_admin
        user.update_attribute('login_on', Time.now)
        
        # if user.is_admin?
        if user.username == 'davedensley'
          redirect_to :controller => "/admin", :action => 'index'
        else
          redirect_back_or_default('/account/')
        end
        
        # if session[:intended_action] and session[:intended_controller]
        #   if session[:intended_id]
        #     redirect_to :action     => session[:intended_action],
        #                 :controller => session[:intended_controller],
        #                 :id         => session[:intended_id]
        #   else
        #     redirect_to :action     => session[:intended_action],
        #                 :controller => session[:intended_controller]
        #   end
        # else
        #   if user.is_admin?
        #     redirect_to :controller => "/admin", :action => 'index'
        #   else
        #     redirect_to :controller => '/account', :action => 'index'
        #   end
        #   # redirect_to :controller => 'listings'
        # end
        # # redirect_to :controller => "/admin"
      end
    else
      render :layout => 'default'
    end
  end

  def logout
    @page_title = "Logout"
    @session[:user] = nil
    @session[:is_admin] = nil
    render :layout => 'default'
  end

  def register
    @page_title = "Register for New Account"
#    @user = User.new(params[:user])
    @user = User.new
  end

  def signup
    @page_title = "Signup For New Account"
    @user = User.new(params[:user])
    @listing_id = params['listing_id']
    if @request.post? and @user.save
      # Automatically add to newsletter subscription
      @user.update_attribute('subscribed', 1)
      @user.update_attribute('subscription_date', Time.now())
      @user.update_attribute('subscription_ip', request.remote_ip)
      begin
        UserNotify.deliver_signup(@user, params[:user][:password])
      rescue
        flash[:notice] = 'Error sending user notification email'
      end

      if @listing_id.blank?
        flash[:notice] = "Thank-you for signing up, #{@user.name}. Please login to continue."
        # redirect_to :controller => 'listings', :action => 'new'
        redirect_to :controller => 'account'
      else
        @listing = Listing.find_by_id(@listing_id)
        @listing.update_attribute('user_id', @user.id)
        # flash[:notice] = 'listing updated with user id'
        flash[:notice] = "Thank-you for signing up, #{@user.name}. Your account will be activated after we receive verification from \'#{@listing.business}\' that you are authorized to edit this listing."
        redirect_to :controller => 'listings', :action => 'index'
      end

    end
  end

  def edit_password
  end

  def change_password
    @user = User.find(session[:user])
    @new_password = params[:new_password]

    if @new_password == params[:new_password_confirmation]
      @salt = get_salt
      @hash = make_hash(@new_password, @salt)
      if @user.update_attribute('password_hash', @hash) and @user.update_attribute('password_salt', @salt)
#      if @user.update_attribute('password', @new_password)
        if params[:send_confirmation] == 'on'
          UserNotify.deliver_change_password(@user, @new_password)
          flash[:notice] = "Password changed, #{@user.name}. A notice was send to your email address."
        else
          flash[:notice] = 'Password changed.'
        end
        redirect_to :action => 'index'
      else
        flash[:notice] = 'Password could not be changed.'
        redirect_back_or_default
        # redirect_to :back
      end
    else
      flash[:notice] = 'Passwords do not match. Please try again.'
      redirect_back_or_default
      # redirect_to :back
    end
  end

  def forgot_password
  end

  def reset_password
    @user = User.find_by_username(params[:username])
    if @user
      if @user.email != params[:email]
        flash[:notice] = 'That is not the correct email address for this account. Please try again.'
        redirect_back_or_default
        # redirect_to :back
      else
        @new_password = random_string(5)
        @salt = get_salt
        @hash = make_hash(@new_password, @salt)
        if @user.update_attribute('password_hash', @hash) and @user.update_attribute('password_salt', @salt)
#        if @user.update_attribute('password', @new_password)
          UserNotify.deliver_reset_password(@user, @new_password)
          flash[:notice] = "#{@user.name}, your new password has been sent to your email address: " << @user.email
          redirect_to :controller => '/listings', :action => 'index'
        else
          flash[:notice] = 'Sorry, there was a problem resetting your password. Please try again.'
          redirect_back_or_default
          # redirect_to :back
        end
      end
    else
      flash[:notice] = 'Sorry, that username is not valid. Please try again.'
      redirect_back_or_default
      # redirect_to :back
    end
  end

  def upgrade
    if params[:listing_id].nil?
      flash[:notice] = 'You must specify a listing to upgrade. Please click the "Upgrade this listing" link on any listing page.'
      redirect_back_or_default
    else
      @listing = Listing.find(params[:listing_id])
      if !@listing
        flash[:notice] = 'Payment failed: Please select a listing that you wish to upgrade'
        redirect_back_or_default
      end
    end
  end

  def upgrade_now
    if params[:listing_id].nil?
      flash[:notice] = 'You must specify a listing to upgrade. Please click the "Upgrade this listing" link on any listing page.'
      redirect_back_or_default
    else
      @listing = Listing.find(params[:listing_id])
      if !@listing
        flash[:notice] = "Payment failed. The listing specified (id: #{params[:listing_id]} ) could not be found."
        redirect_back_or_default
      end
    end
  end

  def upgrade_thanks
  end
    
  def update_subscription
    @user = User.find(session[:user])
    if params[:action_type] == 'subscribe' then
      @user.update_attribute('subscribed', 1)
      flash[:notice] = 'You have been subscribed to the newsletter'
    else
      @user.update_attribute('subscribed', 0)
      flash[:notice] = 'You have been unsubscribed from the newsletter'
    end
    @user.update_attribute('subscription_date', Time.now())
    @user.update_attribute('subscription_ip', request.remote_ip)
    redirect_to :action => 'index'
  end

  def resources
  end

end
