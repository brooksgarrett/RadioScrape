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

credentials =  {'token' => 'BQDC3kgDSqSOlVUAm0ept7lkfIv21NfGCRGvFICHmIsX6MbiOQVY8EHUvfgAm6z6AWMiyOsQNe7UXCemOwO_2SGVHYqBXeu88vCu7ravQMDNAI0qpEXwdn8_j3_mlIVFM2zU_rVdtu8Pi82FDYllAe39mDjX2aWtSJhpdwYf-cxrs7wDI-3KdHTPRk8', 'token_type' => 'Bearer', 'expires_in' => 3600, 'refresh_token' => 'AQBHGe-RKiQo7M2qsxe5Ele99XbpuU21ZybG59JVFoIAGI-gRe32AJpx5nML2-TrP8xTJo8BWMJESOudjciAptEMnuPH17e57ggXeI2oHDd6zbv3EC2R1KicU59um7SLqJs'}

puts credentials

# {"access_token":"BQDC3kgDSqSOlVUAm0ept7lkfIv21NfGCRGvFICHmIsX6MbiOQVY8EHUvfgAm6z6AWMiyOsQNe7UXCemOwO_2SGVHYqBXeu88vCu7ravQMDNAI0qpEXwdn8_j3_mlIVFM2zU_rVdtu8Pi82FDYllAe39mDjX2aWtSJhpdwYf-cxrs7wDI-3KdHTPRk8","token_type":"Bearer","expires_in":3600,"refresh_token":"AQBHGe-RKiQo7M2qsxe5Ele99XbpuU21ZybG59JVFoIAGI-gRe32AJpx5nML2-TrP8xTJo8BWMJESOudjciAptEMnuPH17e57ggXeI2oHDd6zbv3EC2R1KicU59um7SLqJs"}

credentials = {'credentials' => credentials}
puts credentials['credentials']

brooksgarrett = RSpotify::User.new('{"access_token":"BQDC3kgDSqSOlVUAm0ept7lkfIv21NfGCRGvFICHmIsX6MbiOQVY8EHUvfgAm6z6AWMiyOsQNe7UXCemOwO_2SGVHYqBXeu88vCu7ravQMDNAI0qpEXwdn8_j3_mlIVFM2zU_rVdtu8Pi82FDYllAe39mDjX2aWtSJhpdwYf-cxrs7wDI-3KdHTPRk8","token_type":"Bearer","expires_in":3600,"refresh_token":"AQBHGe-RKiQo7M2qsxe5Ele99XbpuU21ZybG59JVFoIAGI-gRe32AJpx5nML2-TrP8xTJo8BWMJESOudjciAptEMnuPH17e57ggXeI2oHDd6zbv3EC2R1KicU59um7SLqJs"}')

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
