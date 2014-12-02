$:.unshift File.dirname(__FILE__)

require 'sinatra'
require 'service'

set :port, ENV['PORT'] if ENV['PORT']

before do
  headers "Content-Type" => "text/plain; charset=utf8"
end

run Sinatra::Application.run!
