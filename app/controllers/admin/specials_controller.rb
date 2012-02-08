class Admin::SpecialsController < ApplicationController

  before_filter :check_admin_authentication

  layout 'admin'

  def index
    @specials = Special.find(:all)
  end

  def feature
    @special = Special.find(params[:id])
    @special.update_attribute('featured', 1)
    redirect_to :action => 'index'
  end

  def unfeature
    @special = Special.find(params[:id])
    @special.update_attribute('featured', 0)
    redirect_to :action => 'index'
  end

end
