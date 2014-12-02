
require 'net/http'

get '/v1/greeting' do
  'Hello ' + (name || 'there') + '!' + "\n"
end

def name
  name_v2 || name_v1 || nil
end

def name_v1
  content_from "http://#{NAME_HOSTNAME_V1}/v1/name"
end

def name_v2
  content_from "http://#{NAME_HOSTNAME_V2}/v2/name"
end

def content_from url
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.open_timeout = 1
  http.read_timeout = 1
  response = Net::HTTP.get_response(uri) rescue nil
  if response && response.code == "200"
    $stderr.puts "BODY:#{response.body}"
    return response.body
  else
    return nil
  end
end

