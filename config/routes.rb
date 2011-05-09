Local::Application.routes.draw do

  root :to => "home#index"
  get "/alert_config", :to =>"settings#alert_config"
  post "/update_alert_config", :to =>"settings#update_alert_config"
  get "/settings/templates", :to => "settings#template_config"
  post "/settings/templates", :to => "settings#update_template_config"

  resources :custom_messages

  resources :users do
    collection do
      get "validate"
    end
  end

  resources :places do
    collection do
      get "import"
      post "upload_csv"
      post "confirm_import"
    end

    resources :users
  end

  resources :sessions, :only =>[:new,:create,:destroy] do
    collection do
      get "signin"
      get "signout"
    end
  end

  resources :alerts do
    collection do
      get "health_center"
      get "village"
    end
  end


  match  '/contact' => "page#contact"
  match  '/about' => "page#about"
  match  "/signup" => "users#new"
  match  "/user_edit/:id" => "users#user_edit"
  match  "/user_update" => "users#user_save"
  match  "/user_cancel/:id" => "users#user_cancel"


  match "/nuntium/receive_at" => "nuntium#receive_at"

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  match ':controller(/:action(/:id(.:format)))'
end
