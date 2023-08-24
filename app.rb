require "sinatra"
require "sinatra/reloader"
require "http"
require "json"
require "sinatra/cookies"

get("/") do
  erb(:root)
end

get("/umbrella") do 

  erb(:umbrella)
end

get("/message") do
  erb(:ai_message)
end

get("/chat") do
  erb(:ai_chat)
end

post("/process_umbrella") do
  @location = params.fetch("location")

  HTTP.get("")
  erb(:umbrella_result)
end
