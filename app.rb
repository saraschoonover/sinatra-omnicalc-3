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
  @location = params.fetch("location").to_s
  gmaps_key = ENV.fetch("GMAPS_KEY")
  gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{user_location}&key=#{gmaps_key}"
  maps_data = HTTP.get(gmaps_url)
  parsed_gmaps_data = JSON.parse(maps_data)
  @results_array = parsed_gmaps_data.fetch("results")

  

  erb(:umbrella_result)
end
