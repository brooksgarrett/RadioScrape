# require 'net/http'
# require 'date'
require 'open-uri'
require 'xmlsimple'
require 'redis'
require 'json'

redis = Redis.new

config = JSON.parse(redis.get('config'))

if (config['debug'] =~ (/^(true|t|yes|y|1)$/i))
  debug = true
else
  debug = false
end

# Have to take 10 seconds off in case we're fast
dNow = Time.now() - 10

dString = dNow.utc.strftime('%m-%d-%H:%M:%S')
stations =  JSON.parse(redis.get('stations'))

config['stations'].each do |station| 
  if (debug)
    puts station
  end

  url = 'https://www.siriusxm.com/metadata/pdt/en-us/xml/channels/' + station + '/timestamp/' + dString
  if (debug)
      puts "URL:" + url
  end
  @data = URI.parse(url).read

  meta = XmlSimple.xml_in(@data, { 'KeyAttr' => 'name' })

  if (meta["messages"][0]["code"][0] == "100") 
    artist 	= meta['metaData'][0]['currentEvent'][0]['artists'][0]['name'][0]
    song	= meta['metaData'][0]['currentEvent'][0]['song'][0]['name'][0]
    if (artist.start_with?('@') || artist.start_with?('#') )
      exit
    elsif (song.start_with?('@') || song.start_with?('#'))
      exit
    end
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
      redis.zadd("playlist:" + station, 1, key)
      if (debug)
        puts '  New Song!'
      end
    else 
      rDetail = JSON.parse(rDetail)
      rDetail["plays"] += 1
      redis.set(key, rDetail.to_json)
      redis.zincrby("playlist:" + station, 1, key)
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
