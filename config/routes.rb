ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"

  map.connect '',        :controller => 'listings',       :action => 'index'
  map.connect 'admin',   :controller => 'admin/listings', :action => 'index'
  map.connect 'about',   :controller => 'about',          :action => 'index'
  map.connect 'contact', :controller => 'about',          :action => 'contact'
  map.connect 'login',   :controller => 'account',        :action => 'login'
  map.connect 'logout',  :controller => 'account',        :action => 'logout'
  map.connect 'new',     :controller => 'listings',       :action => 'new'
  map.connect 'start',   :controller => 'listings',       :action => 'start'
  map.connect 'update',  :controller => 'listings',       :action => 'start'

  map.resources :assets, :member => {:download => :get}

  # list_by_city
  map.connect 'listings/list_by_city/:city/:letter',
    :controller => 'listings',
    :action => 'list_by_city',
    :city => 'all',
    :letter => nil
  
  # map.connect ':controller/:action/:city/:letter',
  #   :city => nil,
  #   :letter => nil
    # :requirements => { :controller => 'listings',
    #                    :action => 'list_by_city' }

  map.connect 'listings/show/:id/:subaction/:image_id',
    :controller => 'listings',
    :action => 'show',
    :subaction => nil,
    :image_id => nil

  # 
  # map.connect ':controller/:action/:id/:subaction/:image_id',
  #   :subaction => nil,
  #   :image_id => nil,
  #   :requirements => { :controller => 'listings',
  #                      :action => 'show' }

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  # map.connect ':controller/service.wsdl', :action => 'wsdl'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
