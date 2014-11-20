Rails.application.routes.draw do
  get 'forgot_password' => 'users#forgot_password'
  get 'reset_password'  => 'users#reset_password'
  
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
        
        resources :posts, only: [:index, :create]
      end
      
      resources :posts, only: [:destroy] do
        get 'up' => 'posts#up'
        resources :comments, only: [:index, :create, :destroy], shallow: true
      end
      get 'aggregate' => 'posts#aggregate'
      get 'comments/:comment_id/up', to: 'comments#up'
      
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
