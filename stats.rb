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
header += 'Plays'
puts header

header  = ''

for i in 1..105
	header += '-'
end
puts header

redis.keys('song:*').each do |key|
	t = JSON.parse(redis.get(key))
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

	line = line + t["plays"].to_s
	puts line
end

