ActionController::Routing::Routes.draw do |map|
  map.resources :events, :collection => {:archive => :get, :map => :get}, :member => {:cancel => :post, :uncancel => :post, :maps_on => :get}
  map.resources :organisations
  map.resource :session

  map.resources :users, :member => { :suspend => :put, :unsuspend => :put, :purge => :delete }, :collection => { :auto_tag_list => :post }

  map.front '/', :controller => 'front', :action => 'current'
  map.tag '/tag/:name', :controller => 'front', :action => 'show', :requirements => {:name => /.*/}
  map.about '/about', :controller => 'front', :action => 'about'
  map.imprint '/imprint', :controller => 'front', :action => 'imprint'
  map.presse '/presse', :controller => 'front', :action => 'presse'
  map.tutorial '/tutorial', :controller => 'front', :action => 'tutorial'
  map.disclaimer '/disclaimer', :controller => 'front', :action => 'disclaimer'
  map.all_cloud 'all', :controller => 'front', :action => 'all'
  map.event_cloud 'demos', :controller => 'front', :action => 'events'
  map.other_cloud 'other', :controller => 'front', :action => 'other'
  map.current_cloud 'current', :controller => 'front', :action => 'current'

  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'

  # only for localhost-testing
  map.switch_lang '/switch_language/:language', :controller => 'languages', :action => 'switch'


  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
