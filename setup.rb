require 'redis'
require 'json'

redis = Redis.new

stations = ['octane', '90salternative']
config = JSON.parse(redis.get('config'))
if (config == nil)
  config = {}
  config['stations'] = ['octane', '90salternative']
  puts "Enter the client_id (from Spotify Dev Area)."
  config['client_id'] = gets.chomp
  puts "Enter the client_secret (from Spotify Dev Area)."
  config['client_secret'] = gets.chomp
  puts "Enter the token"
  config['oauth_token'] = gets.chomp
  puts "Enter the refresh_token"
  config['oauth_refresh_token'] = gets.chomp
  config['oauth_token_type'] = 'Bearer'
  config['oauth_expires_in'] = 3600
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
