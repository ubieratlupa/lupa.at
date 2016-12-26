Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  constraints(host: /^www\./i) do
    get '(*any)' => redirect { |params, request|
      URI.parse(request.url).tap { |uri| uri.host.sub!(/^www\./i, '') }.to_s
    }
  end

  root 'monuments#index'
  
  get 'map' => 'places#map_finding_places'
  
  get 'about', to: 'pages#show', defaults: { id: 'lupa' }
  get 'about/:id', to: 'pages#show', as: :page
  
  # get 'museums/:id' => 'museums#show'

  resources :museums
  resources :places
  resources :queries


  get 'places/:id/finding' => 'places#show_finding'
  get 'places/:id/conservation' => 'places#show_conservation'

  get ':id' => 'monuments#show'
  
  resources :monuments
  
end
