class BlogsController < ApplicationController

  layout 'default'

  def show
    @blog = Blog.find(params[:id])
  end
  
  def index
    @blog_total = Blog.find :all
    @blog_pages, @blogs = paginate :blogs,
                                   :per_page => 20,
                                   # :conditions => ["date_paid_start <= ? and date_paid_expires > ?", @today, @today],
                                   :order => "date_published DESC"
  end
  
end
