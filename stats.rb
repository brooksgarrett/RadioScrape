# require 'net/http'
# require 'date'
require 'open-uri'
require 'xmlsimple'
require 'redis'
require 'json'

redis = Redis.new

header = "Artist"
for i in 1..50-header.length
	header += ' '
end
header += "Song"
for i in 1..100-header.length
      header += ' '
end
header += "Station"
for i in 1..120-header.length
      header += ' '
end
header += 'Plays'
puts header

header  = ''

for i in 1..125
	header += '-'
end
puts header

redis.keys('song:*').each do |key|
	begin
		t = JSON.parse(redis.get(key))
	rescue
		t = JSON.parse(redis.get(key).gsub(/=>/, ':'))
		redis.set(key, t.to_json)
		puts key
	end
        line =  t["artist"]
        pad = 50 - t["artist"].length
	for i in 1..pad	
		line = line + ' '
	end
	line = line + t["song"]
	pad = 50 - t["song"].length
        for i in 1..pad
                line = line + ' '
        end
        line = line + t["station"]
        pad = 20 - t["station"].length
        for i in 1..pad
                line = line + ' '
        end

	line = line + t["plays"].to_s
	puts line
end

