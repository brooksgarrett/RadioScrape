# require 'net/http'
# require 'date'
require 'open-uri'
require 'xmlsimple'
require 'redis'
require 'json'
require 'rspotify'

redis = Redis.new
RSpotify.authenticate(ENV['S_CLIENT_ID'], ENV['S_CLIENT_SECRET'])

station = "octane"

brooksgarrett = RSpotify::User.find('brooksgarrett')

puts brooksgarrett.id

exit

station_list = nil

user.playlists.each do |playlist|
    if (playlist.name == station)
        station_list = playlist
        break
    end
end

if (station_list == nil)
    station_list = user.create_playlist!(station)
end


list = redis.zrevrange('playlist:octane', 0, -1)

list.each do |song|
  song = redis.get(song)
  puts song
end
