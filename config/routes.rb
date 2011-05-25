Local::Application.routes.draw do

  devise_for :users

  root :to => "home#index"
  get "/alert_config", :to =>"settings#alert_config"
  post "/update_alert_config", :to =>"settings#update_alert_config"
  get "/settings/templates", :to => "settings#template_config"
  post "/settings/templates", :to => "settings#update_template_config"
  match "map_report/:id" => "places#map_report" , :as => "map_report"
  resources :custom_messages

  resources :map_visualizations do
    collection do
      get "map_report"
      get "map_view"
    end
  end
  resources :reports
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
      get "map_view"
      get "map_report"
    end

    resources :users
  end

  resources :thresholds

  match  '/contact' => "page#contact"
  match  '/about' => "page#about"
  match  "/signup" => "users#new"
  match  "/user_edit/:id" => "users#user_edit"
  match  "/user_update" => "users#user_save"
  match  "/user_cancel/:id" => "users#user_cancel"

  match "/nuntium/receive_at" => "nuntium#receive_at"

  match ':controller(/:action(/:id(.:format)))'
end
