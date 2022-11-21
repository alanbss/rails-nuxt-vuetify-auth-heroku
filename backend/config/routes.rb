Rails.application.routes.draw do  
  scope :api, defaults: {format: :json} do
    resources :private_contents, :public_contents
    get '/current_user', to: 'current_user#index'
    devise_for :users, path: '', path_names: {
      sign_in: 'login',
      sign_out: 'logout',
      registration: 'signup'
    },
    controllers: {
      sessions: 'users/sessions',
      registrations: 'users/registrations'
    }
  end
end