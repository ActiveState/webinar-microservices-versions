
require 'net/http'
require 'json'

get '/v3/greeting' do
  (hi_word || 'Hello').strip + ' ' + (name || 'there').strip + '!' + "\n"
end

def name
  name_v2 || name_v1 || nil
end

def hi_word
  hi_word_v1 || nil
end

def name_v1
  content_from "http://name-v1.#{ENV['BASE_HOSTNAME']}/v1/name"
end

def name_v2
  json = content_from "http://name-v2.#{ENV['BASE_HOSTNAME']}/v2/name"
  return nil if json.nil?
  names = JSON.parse(json)
  return stringify_names(names)
end

def hi_word_v1
  content_from "http://hi-word-v1.#{ENV['BASE_HOSTNAME']}/v1/hi-word"
end

def stringify_names names
  names = names.dup
  last_name = names.pop
  if names.size > 0
    names.join(", ") + " and " + last_name
  else
    last_name
  end
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

