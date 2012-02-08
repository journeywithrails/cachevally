class Admin::BlogsController < ApplicationController

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
      @blog_total = Blog.find(:all)
      @blog_pages, @blogs = paginate :blogs, :per_page => 20
    end

    def show
      @blog = Blog.find(params[:id])
      session[:return_to] = {:controller => "/admin/blogs", :action => "show", :id => @blog.id}
    end

    def new
      @blog = Blog.new
      @blog.date_published = Time.new
    end

    def create
      @blog = Blog.new(params[:blog])
      if @blog.save
        flash[:notice] = 'Blog entry was successfully created.'
        redirect_to :action => 'list'
      else
        render :action => 'new'
      end
    end

    def edit
      @blog = Blog.find(params[:id])
    end

    def update
      @blog = Blog.find(params[:id])
      if @blog.update_attributes(params[:blog])
        flash[:notice] = 'Blog entry was successfully updated.'
        redirect_to :action => 'show', :id => @blog
      else
        render :action => 'edit'
      end
    end

    def destroy
      Blog.find(params[:id]).destroy
      flash[:notice] = 'Blog entry was deleted.'
      redirect_to :action => 'list'
    end

end
