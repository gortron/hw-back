Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  get '/api/ping' => "server#ping", as: :ping
  get '/api/posts' => "server#posts", as: :posts
end
