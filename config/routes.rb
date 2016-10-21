Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  constraints(host: /^www\./i) do
    get '(*any)' => redirect { |params, request|
      URI.parse(request.url).tap { |uri| uri.host.sub!(/^www\./i, '') }.to_s
    }
  end

  root 'places#map_finding_places'

  get 'about' => 'pages#about'
  
  # get 'museums/:id' => 'museums#show'

  resources :museums
  resources :places

  get 'places/:id/finding' => 'places#show_finding'
  get 'places/:id/conservation' => 'places#show_conservation'

  get ':id' => 'monuments#show'
  
  resources :monuments
  
end
