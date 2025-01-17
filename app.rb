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

post("/process_message"){
  @message = params.fetch("message")
  
  request_headers_hash = {
    "Authorization" => "Bearer #{ENV.fetch("NEW_OPENAI_KEY")}",
    "content-type" => "application/json"
    }
  
    request_body_hash = {
      "model" => "gpt-3.5-turbo",
      "messages" => [
        {
          "role" => "user",
          "content" => @message
        }
      ]
    }
  
    request_body_json = JSON.generate(request_body_hash)
  
    raw_response = HTTP.headers(request_headers_hash).post(
      "https://api.openai.com/v1/chat/completions",
      :body => request_body_json
    )

    @parsed_response = JSON.parse(raw_response)

    #@reply = @parsed_response.dig("choices", 0, "message", "content")

  erb(:ai_message_result)
}

get("/chat") do
  if (cookies["chat_history"] == nil)
    @chat_history = []
    cookies["chat_history"] = JSON.generate(@chat_history)
  else
    @chat_history = JSON.parse(cookies["chat_history"])
  end
  erb(:ai_chat)
end

post("/chat"){

  @user_message = params.fetch("user_input")

  request_headers_hash = {
    "Authorization" => "Bearer #{ENV.fetch("NEW_OPENAI_KEY")}",
    "content-type" => "application/json"
  }

  request_body_hash = {
    "model" => "gpt-3.5-turbo",
    "messages": [
    {
      "role": "user",
      "content": @user_message
    }
  ]
  }

  request_body_json = JSON.generate(request_body_hash)

  raw_response = HTTP.headers(request_headers_hash).post(
    "https://api.openai.com/v1/chat/completions",
    :body => request_body_json
  )

  @chat_history = JSON.parse(cookies["chat_history"]) 

  @parsed_response = JSON.parse(raw_response).dig("choices", 0, "message","content") 

  @chat_history.push({"role" => "user", "content" => @user_message})
  @chat_history.push({"role"=> "assistant", "content"=> @parsed_response})
  cookies["chat_history"] = JSON.generate(@chat_history)

  erb(:ai_chat)
}

post("/clear_chat"){
  cookies["chat_history"] = JSON.generate([])
  redirect(:chat)
}

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
