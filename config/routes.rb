ActionController::Routing::Routes.draw do |map|

  map.root :controller => 'home'
  map.home ':page', :controller => 'home', :action => 'show', :page => /faq|contact|privacy|iphone|web|iphone_check_email_confirmation|iphone_account_confirmed/

  map.resource :account, :controller => "users"
  
  map.resource :list_order, :controller => "list_order"
  map.resource :device_token, :controller => "device_token"
  
  map.resource :frack, :controller => "frack"
  
  map.resource :user_list_order, :controller => "user_list_order"

  map.resource :perishable_token, :controller => "perishable_token"
  
  map.resource :feed, :controller => 'feed'
  
  map.resources :lists, :has_many => [ :items, :collaborators ] do |lists|
    lists.resource :bulk_update, :controller => 'bulk_update'
  end
  
  map.resource :list_watch, :controller => 'list_watch'
  
  map.resources :user_list_links
  
  map.resources :users, :has_many => [ :lists ]
  
  map.resource :user_session
  map.root :controller => "user_sessions", :action => "new"

  map.resources :password_resets

  map.resources :api_authentication
  map.resource :username
  
  map.confirm_email 'email_confirmations/:id', :controller => 'email_confirmations', :action => 'new'
  
  map.subscription_redirect 'subscription_redirect', :controller => 'users', :action => 'show'  
end
