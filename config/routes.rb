Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  constraints(host: /^www\./i) do
    get '(*any)' => redirect { |params, request|
      URI.parse(request.url).tap { |uri| uri.host.sub!(/^www\./i, '') }.to_s
    }
  end

  root 'monuments#index'
  
  get 'map' => 'places#map'
  
  get 'about', to: 'pages#show', defaults: { id: 'lupa' }
  get 'about/:id', to: 'pages#show', as: :page
  
  resources :museums
  resources :collections
  resources :places
  resources :regional_infos
  resources :queries do
    get 'qr', :on => :member
    get 'completions/:field', :on => :collection, :action => 'completions'
    get 'suggestions/:field', :on => :collection, :action => 'suggestions'
  end


  get 'places/:id/finding' => 'places#show_finding'
  get 'places/:id/conservation' => 'places#show_conservation'
  get 'places/:id/museums' => 'places#show_museums'

  get ':id' => 'monuments#show'
  
  get ':id/photos/:page' => 'monuments#photos'
  get ':id/photos/' => 'monuments#photos', defaults: { page: 1 } 
  
  resources :monuments do
    get 'qr', :on => :member
    get 'recent', :on => :collection
  end
  
  resources :authors do
    get 'photo', :on => :collection
  end
  
end
