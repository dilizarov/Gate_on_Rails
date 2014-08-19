Rails.application.routes.draw do
  devise_for :users
  
  namespace :api do
    namespace :v1 do
      devise_scope :user do
        post   'registrations' => 'registrations#create', as: 'register'
        post   'sessions'      => 'sessions#create',      as: 'login'
        delete 'sessions'      => 'sessions#destroy',     as: 'logout'
      end
    end
  end
end
