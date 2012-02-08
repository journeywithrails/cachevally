class Admin::AssetsController < ApplicationController

  def list
    @assets = Asset.find(:all)
  end

  def new
    @asset = Asset.new
  end

  def create
    @assest = Asset.new(params[:asset])
    if @asset.save
      flash[:notice] = 'Asset was successfully created.'
      redirect_to asset_url(@asset)     
    else
      render :action => :new
    end
  end
  
  def show
    @asset = Asset.find(params[:id])
  end

  def update
    @asset = update_attributes(params[:asset])
  end

  def edit
    @asset = Asset.find(parms[:id])
  end

  def destroy
    @asset = Asset.find(params[:id])
  end
  
end
