class Admin::AccountController < ApplicationController

  before_filter :check_admin_authentication
  
  layout 'admin'
  
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @user_total = User.find :all
    @user_pages, @users = paginate :users, :per_page => 20
#    @users = User.find(:all)
  end

  def show
    @user = User.find(params[:id])
    @listings = Listing.find_all_by_user_id(@user.id)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = 'User was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = 'User was successfully updated.'
      redirect_to :action => 'show', :id => @user
    else
      render :action => 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
  
  def view_subscriptions
    # @subscriptions = User.find :all
    # :conditions => ["date_paid_start <= ? and date_paid_expires > ?", @today, @today],

    @subscriptions = User.find_all_by_subscribed(1)

  end
  
end
