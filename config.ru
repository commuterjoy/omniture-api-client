
require 'rubygems'
require 'sinatra'

root = ::File.dirname(__FILE__)

puts root

require ::File.join( root, 'http.rb' )
require ::File.join( root, 'lib', 'omniture.rb' )

run OmnitureServer

