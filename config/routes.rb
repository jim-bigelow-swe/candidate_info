CandidateInfo::Application.routes.draw do
  # contributions can only be added via service and not
  # individualy via a form, they cannot be updated or edited
  # once added.
  #
  # candidates and contributors cannot be added separately
  # they are added as a part of adding a contribtion
  #
  # cadidates & contributors can only be listed, shown and editing
  # editing for candidates is limited to marking them elected
  # editing for contributors is limited to
  #  - combining a contributor with another when they are alternative spellings
  #    of the same contributor
  #  - marking if the contributor is a PAC, Company, or Person
  #
  resources :contributions, :except => [:update, :edit]

  resources :contributors, :only => [:index, :show, :edit]

  resources :candidates,  :only => [:index, :show, :edit]

  get "home/index"

  root :to => 'home#index'

end
