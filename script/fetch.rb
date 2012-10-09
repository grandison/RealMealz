require 'net/http'

def fetch_if_modified(link)
  uri = URI(link)
  file = File.stat 'cached_response'

  req = Net::HTTP::Get.new(uri.request_uri)
  req['If-Modified-Since'] = file.mtime.strftime("%a, %d %b %Y %T %z") # rfc2822

  res = Net::HTTP.start(uri.hostname, uri.port) {|http|
    http.request(req)
  }

  if res.is_a?(Net::HTTPSuccess)
    puts "Newer file, writing"
    open 'cached_response', 'w' do |io|
      io.write res.body
    end
  end
end

def fetch(link)
  uri = URI(link)
  result = Net::HTTP.get(uri)

  filename = "fetch_#{Time.now.strftime('%Y-%m-%dT%H-%M')}.rss"
  puts "Wrote #{filename}"
  open filename, 'w' do |io|
    io.write result
  end
end

def fetch_every(minutes, link)
  while true do
    fetch(link)
    puts "Next fetch in #{minutes} minutes"
    sleep(minutes * 60)
  end
end

fetch_every(5, 'http://syndication.ap.org/AP.Distro.Feed/GetFeed.aspx?idList=44516&idListType=products&maxItems=10&fullcontent=NITF&un=msnmoney_webfeed&pwd=ap116')