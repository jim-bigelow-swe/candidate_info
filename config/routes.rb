CandidateInfo::Application.routes.draw do
  resources :contributions

  resources :contributors

  resources :candidates

  get "home/index"

  root :to => 'home#index'

end
