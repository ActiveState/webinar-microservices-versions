$:.unshift File.dirname(__FILE__)

require 'sinatra'
require 'service'

set :port, ENV['PORT'] if ENV['PORT']

if ENV['VCAP_SERVICES']
  DOMAIN = "192.168.97.139.xip.io"
  NAME_HOSTNAME_V1 = 'name.' + DOMAIN
  NAME_HOSTNAME_V2 = 'name.' + DOMAIN
  NAME_HOSTNAME_V3 = 'name.' + DOMAIN
else
  DOMAIN = "localhost:5678"
  NAME_HOSTNAME_V1 = DOMAIN
  NAME_HOSTNAME_V2 = DOMAIN
  NAME_HOSTNAME_V3 = DOMAIN
end


before do
  headers "Content-Type" => "text/plain; charset=utf8"
end

run Sinatra::Application.run!
