
require 'net/http'
require 'json'

get '/' do
  content
end

def content
  [4,3,2,1].each do |version|
    content = content_from "http://greeting-v#{version}.#{ENV['BASE_HOSTNAME']}/v#{version}/greeting"
    return content if content
  end
  "Service is down"
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

