Rails.application.routes.draw do
  get "/check" => "check#index"
  get "/lighthouse" => "lighthouse#index"
  get "/uptime" => "uptime#index"
end
