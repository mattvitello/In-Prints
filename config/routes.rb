Rails.application.routes.draw do
  root 'home#index'
  get 'top', to: 'top#top'
  get 'new', to: 'new#new'
  get 'hot', to: 'hot#hot'

  get '/new/sweatshirts', to: 'new#sweatshirts'
  get '/new/wallart', to: 'new#wallart'
  get '/new/hats', to: 'new#hats'

  get '/top/sweatshirts', to: 'top#sweatshirts'
  get '/top/wallart', to: 'top#wallart'
  get '/top/hats', to: 'top#hats'

  get '/tweet/random_top', to:'tweet#random_top'
  get 'trend', to: 'trend#trend'
end
