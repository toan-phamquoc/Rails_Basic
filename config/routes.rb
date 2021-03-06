Rails.application.routes.draw do
  # default
    devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
    root 'home#index'
    get 'home', to: 'home#index'
    get 'friends', to: 'friends#index'
 
    get 'friends/index'
    get 'friends/addfriend'
    get 'friends/unfriend'






    resources :myfiles, only: [:index, :new, :create, :destroy]
    get 'myfiles/delete'
    get 'myfiles/edit'
    

  resources :messages, only: [:create, :new, :inbox, :sent]
  get 'messages/index'
  get 'messages/inbox', to: 'messages#inbox'
  get 'messages/sent', to: 'messages#sent'
  get 'messages/show', to: 'messages#show'
  get 'friends/block'
  get 'friends/unblock'
  resources :messages do
    collection do
      get 'getmess'
    end
  end








end
