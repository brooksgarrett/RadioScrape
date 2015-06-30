# require 'net/http'
# require 'date'
require 'open-uri'
require 'xmlsimple'
require 'redis'
require 'json'

redis = Redis.new

enable_padding = false

def pad(num, content)
	pad_length = num - content.length
	for i in 1..pad_length
		content += ' '
	end
	content
end

if enable_padding
	header = pad(40, "Artist") + pad(60, "Song") + pad(15, "Station") + "Plays"
else
	header = ("Artist|Song|Station|Plays")
end

puts header



if enable_padding
	header  = ''
	for i in 1..125
		header += '-'
	end
	puts header
end

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
        line = line + '|' + t["station"]
        pad = 20 - t["station"].length
        for i in 1..pad
                line = line + ' '
        end

	line = line + '|' + t["plays"].to_s
	if enable_padding
		puts pad(40, t["artist"]) + pad(60, t["song"]) + pad(15, t["station"]) + t["plays"].to_s
	else
		puts t["artist"] + '|' + t["song"] + '|' + t["station"] + '|' + t["plays"].to_s
	end
end

