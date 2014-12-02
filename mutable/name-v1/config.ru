$:.unshift File.dirname(__FILE__)

require 'sinatra'
require 'service'

set :port, ENV['PORT'] if ENV['PORT']

run Sinatra::Application.run!
