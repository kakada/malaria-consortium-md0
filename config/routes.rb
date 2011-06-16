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
      get "pushpin"
    end
  end
  resources :reports do
    collection do
      get "report_form"
      get "report_detail"
      get "report_csv"
    end
    member do
      get 'generated_messages'
    end
  end
  resources :users do
    member do
      get 'mark_as_investigated'
      get 'reports'
    end
    collection do
      get "validate"
      post "create_new"
      get "import_form"
      get "csv_template"
      get "upload_csv"
      get "confirm_import"
    end
  end

  resources :places do
    collection do
      get "import"
      post "upload_csv"
      get "csv_template"
      post "confirm_import"
      get "map_view"
      get "map_report"
      get 'autocomplete'
    end

    resources :users
  end

  resources :thresholds

  match "/nuntium/receive_at" => "nuntium#receive_at"

  match ':controller(/:action(/:id(.:format)))'
end
