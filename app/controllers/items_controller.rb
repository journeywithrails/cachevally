class ItemsController < ApplicationController

  before_filter :check_admin_authentication
  layout 'admin'

  def index
    @conditions = ["resource_type is null and parent_id is null"]
    @items = Item.find(:all, :conditions => @conditions)
  end

  def new
    @item = Item.new
  end

  def create
    @item = Item.new(params[:item])
    if @item.valid? and @item.save
      flash[:notice] = "Item saved!"
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def edit
    @item = Item.find(params[:id])
  end

  def update
    @item = Item.find(params[:id])
    if @item.update_attributes(params[:item])
      flash[:notice] = 'Item was successfully updated.'
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end

  def destroy
    @item = Item.find(params[:id])
    @item.destroy
    flash[:notice] = "Item deleted!"
    redirect_to :action => 'index'
  end

end
