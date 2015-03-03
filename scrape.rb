# require 'net/http'
# require 'date'
require 'open-uri'
require 'xmlsimple'
require 'redis'
require 'json'

redis = Redis.new
debug = false

dString = Time.now().utc.strftime('%m-%d-%H:%M:%S')
stations = ['octane', '90salternative']
stations.each do |station| 
  if (debug)
    puts station
  end

  url = 'https://www.siriusxm.com/metadata/pdt/en-us/xml/channels/' + station + '/timestamp/' + dString
  @data = URI.parse(url).read

  meta = XmlSimple.xml_in(@data, { 'KeyAttr' => 'name' })


  if (meta["messages"][0]["code"][0] == "100") 
    artist 	= meta['metaData'][0]['currentEvent'][0]['artists'][0]['name'][0]
    song	= meta['metaData'][0]['currentEvent'][0]['song'][0]['name'][0]
    detail = {:artist => artist, :song => song, :plays => 1, :station =>station}
    key = 'song:' + Digest::MD5.hexdigest(detail[:artist]+detail[:song])
    if (debug)
      puts "  Artist:" + artist
      puts "  Song:" + song
      puts "  Station:" + station
    end

    if (redis.get("last:" + station) == key)
      if (debug)
        puts "  Song hasn't changed yet."
      end
      next
    end

    rDetail = redis.get(key)
    if (rDetail == nil)
      redis.set(key, detail.to_json)
      if (debug)
        puts '  New Song!'
      end
    else 
      rDetail = JSON.parse(rDetail)
      rDetail["plays"] += 1
      redis.set(key, rDetail.to_json)
      if (debug)
        puts '  Already heard this'
      end
    end
    redis.set("last:" + station, key)
  else
    if (debug)
      puts '  Failed request.'
    end
  end
end
