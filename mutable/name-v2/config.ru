$:.unshift File.dirname(__FILE__)

require 'sinatra'
require 'service'

run Sinatra::Application.run!
