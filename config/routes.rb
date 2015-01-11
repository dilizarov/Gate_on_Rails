Rails.application.routes.draw do
  get 'forgot_password' => 'users#forgot_password'
  get 'reset_password'  => 'users#reset_password'
  
  namespace :api do
    namespace :v1 do
      devise_for :users, only: :registrations, path: '/registrations'
      
      post 'sessions'             => 'sessions#create',      as: 'login'
      post 'sessions/logout'      => 'sessions#destroy',     as: 'logout' #Yup, it's a post. Volley for Android acts up on delete & at this point, I just want to release this.
      
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
    end
  end
end
