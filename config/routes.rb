Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  mount V1::Base => '/'
  mount GrapeSwaggerRails::Engine, at: "/docs"
end