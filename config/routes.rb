Local::Application.routes.draw do

  devise_for :users

  root :to => "home#index"
  get "/reminder_config", :to => "settings#reminder_config"
  post "/update_reminder_config", :to => "settings#update_reminder_config"
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
  
  namespace :referral do
    root :to => "reports#index"
    get "templates/configs/" , :to => "templates#configs"
    post "templates/update_configs/" , :to => "templates#update_configs"
    
    post "fields/bulk",             :to => "fields#bulk_update"
    post "fields/constraint",       :to => "fields#constraint"
    delete "fields/rm_constraint",  :to => "fields#rm_constraint"
    get  "constraints/view/",       :to => "constraints#view"
    
    post "report/delate_all",       :to => "reports#delete_all"
    
    post "message_formats/save" ,   :to => "message_formats#save"
    get  "message_formats/test" ,   :to => "message_formats#test"
    
    get "reports/rectify",        :to => "reports#rectify"
    post "reports/apply",         :to => "reports#apply"
    
    match "reports/simulate",  :to => "reports#simulate"
    match "reports/duplicated",  :to => "reports#duplicated"
    match "reports/ignored",  :to => "reports#ignored"
    match "reports/error",  :to => "reports#error"
    
    match "reports/valid",    :to => "reports#valid"
    match "reports/toggle",    :to => "reports#toggle"
    match "reports/search",    :to => "reports#search"
    match "reports/confirmed",    :to => "reports#confirmed"
    match "reports/not_confirmed",    :to => "reports#not_confirmed"
    
    match "users/search"  , :to => "users#search"
    match "users/edit-md0", :to => "users#edit_md0"
    
    
    resources :reports
    resources :message_formats
    resources :dashboards 
    resources :users
    resources :fields do
      resources :constraints
    end
    
  end
  
  resources :reports do
    collection do
      get "list_ignore"
      get "error"
      get "last_error_per_sender_per_day"
      get "places_reporting_and_not_reporting"
      get "report_detail"
      get "report_csv"
      get "duplicated"
    end
    member do
      get 'generated_messages'
      get 'ignore'
      get 'stop_ignoring'
    end
  end
  resources :users do
    member do
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
      get 'retrieve_parent'
      get 'check_code'
    end

    resources :users
  end

  resources :thresholds

  resources :alert_pf_notification, :only => [:index]

  match "/nuntium/receive_at" => "nuntium#receive_at"

  match ':controller(/:action(/:id(.:format)))'
end