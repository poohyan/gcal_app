Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # get 'start/index'
  root :to => 'start#index'
  get 'signout' => 'start#signout'

  get 'oauth2authorize' => 'auth#oauth2authorize'
  get 'oauth2callback'  => 'auth#oauth2callback'
  # root :to => 'auth#result'
  get 'go-auth'  => 'auth#result'

  resources :users

  resources :calender do
    collection do
      post 'getDetail'
    end
  end

  get ':controller(/:action(/:id))(.:format)'

end
