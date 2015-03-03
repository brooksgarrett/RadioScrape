# require 'net/http'
# require 'date'
require 'open-uri'
require 'xmlsimple'
require 'redis'
require 'json'

redis = Redis.new

dString = Time.now().utc.strftime('%m-%d-%H:%M:%S')
stations = ['octane', '90salternative']
stations.each { |station| 
puts station
url = 'https://www.siriusxm.com/metadata/pdt/en-us/xml/channels/' + station + '/timestamp/' + dString
@data = URI.parse(url).read

meta = XmlSimple.xml_in(@data, { 'KeyAttr' => 'name' })


if (meta["messages"][0]["code"][0] == "100") 
    artist 	= meta['metaData'][0]['currentEvent'][0]['artists'][0]['name'][0]
    song	= meta['metaData'][0]['currentEvent'][0]['song'][0]['name'][0]
    detail = {:artist => artist, :song => song, :plays => 1, :station =>station}
    key = 'song:' + Digest::MD5.hexdigest(detail[:artist]+detail[:song])

    if (redis.get("last") == key)
	    next
    end

    rDetail = redis.get(key)
    if (rDetail == nil)
	    redis.set(key, detail.to_json)
	    puts 'New Song!'
    else 
	    rDetail = JSON.parse(rDetail)
	    rDetail["plays"] += 1
	    redis.set(key, rDetail.to_json)
	    puts 'Already heard this'
    end
    redis.set("last", key)

else
    puts 'Failed request.'
end
}
