require 'redis'
require 'json'

redis = Redis.new

redis.keys('song:*').each do |key|
	begin
			t = JSON.parse(redis.get(key))
	rescue
			t = JSON.parse(redis.get(key).gsub(/=>/, ':'))
			redis.set(key, t.to_json)
			puts key
	end
	redis.zadd("playlist:" + t['station'], t['plays'], key)
end
