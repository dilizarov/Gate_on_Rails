Rails.application.routes.draw do
  get 'forgot_password' => 'users#send_forgot_password_email'
  get 'reset_password'  => 'users#reset_password_page'
  get 'reset_password_action' => 'users#reset_password'
  
  namespace :api do
    namespace :v1 do
      devise_for :users, only: :registrations, path: '/registrations'
      
      post 'sessions'             => 'sessions#create',      as: 'login'
      post 'sessions/logout'      => 'sessions#destroy',     as: 'logout'
      put  'sessions/update_location' => 'sessions#update_location'
      
      resources :gates, only: [:create, :index, :show] do
        member do
          delete 'leave'
        end
        
        resources :posts, only: [:index, :create]
      end
            
      resources :posts, only: [:destroy, :show] do
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
      
      resources :generated_gates, only: [] do
        post 'process' => 'generated_gates#prokess', on: :collection
        delete 'leave' => 'generated_gates#leave', on: :collection
        put 'unlock' => 'generated_gates#unlock', on: :member
      end
    end
  end
  
  root to: 'users#index'
end
