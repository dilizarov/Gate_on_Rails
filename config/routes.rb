Rails.application.routes.draw do
  devise_for :users
  
  namespace :api do
    namespace :v1 do
      devise_scope :user do
        post   'registrations' => 'registrations#create', as: 'register'
        post   'sessions'      => 'sessions#create',      as: 'login'
        delete 'sessions'      => 'sessions#destroy',     as: 'logout'
      end
      
      resources :networks, only: [:create, :index, :show] do
        member do
          delete 'leave'
        end
        
        resources :posts, only: [:create]
      end
      
      resources :posts, only: [:destroy] do
        resources :comments, only: [:create, :destroy], shallow: true
      end
      
      resources :keys, only: [:create, :destroy, :index] do
        member do
          post 'process', to: 'keys#prokess'
        end
      end
            
      resource :gatekeeper_hq, only: [:show]
    end
  end
end
