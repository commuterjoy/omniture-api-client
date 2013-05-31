
require 'rubygems'
require 'sinatra'

root = ::File.dirname(__FILE__)

require ::File.join( root, 'lib', 'omniture' )
require ::File.join( root, 'util', 'fixnum' )
require ::File.join( root, 'http' )

run OmnitureServer

