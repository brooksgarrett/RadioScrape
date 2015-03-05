# require 'net/http'
# require 'date'
require 'open-uri'
require 'xmlsimple'
require 'redis'
require 'json'
require 'rspotify'

redis = Redis.new

config = JSON.parse(redis.get('config'))

RSpotify.authenticate(config['client_id'],config['client_secret'])

station = "octane"

# Set the options hash with our authentication information and userid
options = {}
credentials = {}

credentials['token'] = config['oauth_token']
credentials['token_type'] = config['oauth_token_type']
credentials['expires_in'] = config['oauth_expires_in'].to_i
credentials['refresh_token'] = config['oauth_refresh_token']

options['id'] = 'brooksgarrett'
options['credentials'] = credentials

# Initialize the user object
user = RSpotify::User.new(options)

# Do we have a playlist for the station?
playlist = nil


user.playlists.each do |temp_playlist|
    if (temp_playlist.name == station)
        playlist = temp_playlist
        break
    end
end

# If not then create it
if (playlist == nil)
    playlist = user.create_playlist!(station)
end

list = redis.zrevrange('playlist:octane', 0, 50)
playlist_tracks = []

list.each do |song|
  data = JSON.parse(redis.get(song))
  data['artist'] = data['artist'].gsub(':', ' ')
  data['song'] = data['song'].gsub(':', ' ')
  begin
    tracks = RSpotify::Track.search(data['song'] + " " + data['artist'], limit: 1)
    if (tracks.total == 0)
      puts data
      next
    else
      playlist_tracks.push(tracks.first)
    end
  rescue
    puts data
  end

end

playlist.replace_tracks!(playlist_tracks)
