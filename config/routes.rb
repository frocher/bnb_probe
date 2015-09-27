Rails.application.routes.draw do
  get "/check" => "check#index"
  get "/uptime" => "uptime#index"
end
