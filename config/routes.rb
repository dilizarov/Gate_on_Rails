Rails.application.routes.draw do
  get 'forgot_password' => 'users#forgot_password'
  get 'reset_password'  => 'users#reset_password'
  
  namespace :api do
    namespace :v1 do
      devise_for :users, only: :registrations, path: '/registrations'
      
      post   'sessions'      => 'sessions#create',      as: 'login'
      post   'sessions'      => 'sessions#destroy',     as: 'logout'
      
      resources :networks, only: [:create, :index, :show] do
        member do
          delete 'leave'
        end
        
        resources :posts, only: [:index, :create]
      end
      
      resources :posts, only: [:destroy] do
        member do
          get 'up'
        end
        resources :comments, only: [:index, :create, :destroy], shallow: true
      end
      get 'aggregate' => 'posts#aggregate'
      get 'comments/:id/up', to: 'comments#up'
      
      resources :keys, only: [:create, :destroy, :index] do
        member do
          post 'process', to: 'keys#prokess'
        end
      end
            
      resources :gatekeepers, only: [] do
        post 'grant_access' => 'gatekeepers#grant_access'
      end
    end
  end
end
