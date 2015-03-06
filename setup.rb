require 'redis'
require 'json'
require 'net/https'
require 'uri'


redis = Redis.new

stations = ['octane', '90salternative']
config = redis.get('config')
if (config == nil)
  config = {}
  config['stations'] = ['octane', '90salternative']
  puts "Enter the client_id (from Spotify Dev Area)."
  config['client_id'] = gets.chomp
  puts "Enter the client_secret (from Spotify Dev Area)."
  config['client_secret'] = gets.chomp
  puts "Now go here and copy your code: https://accounts.spotify.com/authorize?response_type=code&client_id=%s&scope=playlist-modify&redirect_uri=http://brooksgarrett.com/projects/radioscrape/callback.html" % [config['client_id']]
    
  # Base64 encode id and secret
  puts "Code:"
  code = gets.chomp
  
 
  uri = URI.parse('https://accounts.spotify.com/api/token')
  # Full control
  http = Net::HTTP.new(uri.host, uri.port)
 
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE 
  # http.set_debug_output($stdout)
 
  request = Net::HTTP::Post.new(uri.request_uri)
  request.basic_auth config['client_id'], config['client_secret']
  request.set_form_data({'grant_type' => 'authorization_code', 'code' => code, 'redirect_uri' => 'http%3A%2F%2Fbrooksgarrett.com%2Fprojects%2Fradioscrape%2Fcallback.html'})
  
  response = http.request(request)
  
  oauth_data = JSON.parse(response.body)
  
  config['oauth_token'] = oauth_data['access_token']
  config['oauth_refresh_token'] = oauth_data['refresh_token']

  redis.set('config', config.to_json)
else
  config = JSON.parse(redis.get('config'))
end
puts "Enter debug state (true || false)"
config['debug'] = gets.chomp

redis.set('config', config.to_json)

# This doesn't do anything on a new install
# This will clean up an existing database

config['stations'].each do |station|
  redis.del('playlist:' + station)
end



redis.keys('song:*').each do |key|
  begin
    t = JSON.parse(redis.get(key))
    if (t['artist'].start_with?("#") || t['song'].start_with?("#") || t['artist'].start_with?("@") || t['song'].start_with?("@"))
      redis.del(key)
    end
  rescue
   t = JSON.parse(redis.get(key).gsub(/=>/, ':'))
   redis.set(key, t.to_json)
   puts key
  end
  redis.zadd("playlist:" + t['station'], t['plays'], key)
end
