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
  @user_location = params.fetch("location")
  gmaps_key = ENV.fetch("GMAPS_KEY")
  gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{@user_location}&key=#{gmaps_key}"
  maps_data = HTTP.get(gmaps_url).to_s
  parsed_gmaps_data = JSON.parse(maps_data)
  @results_array = parsed_gmaps_data.fetch("results")[0]
  @lat = @results_array.fetch("geometry").fetch("location").fetch("lat")
  @lng = @results_array.fetch("geometry").fetch("location").fetch("lng")

  pirate_weather_url = "https://api.pirateweather.net/forecast/#{ENV.fetch("PIRATE_WEATHER_KEY")}/#{@lat},#{@lng}"
  weather_data = HTTP.get(pirate_weather_url)
  parsed_weather_data = JSON.parse(weather_data)
  @current_temp = parsed_weather_data.fetch("currently").fetch("temperature")
  @current_summary = parsed_weather_data.fetch("currently").fetch("summary")
  try = parsed_weather_data.fetch("currently").fetch("precipProbability")

  if try > 0.10
    @umbrella = "You will probably need an umbrella"
  else
    @umbrella = "You will not need an umbrella"
  end
  erb(:umbrella_result)
end
