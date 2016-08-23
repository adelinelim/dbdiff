require "mysql2"
require "pry"
require "rubygems"
require "bundler/setup"
require "active_support/all"
require "pg"
require "yaml"
require "hashie"

Dir[File.dirname(__FILE__) + "/core_ext/*.rb"].each do |file|
  require_relative file
end

Dir[File.dirname(__FILE__) + "/components/*.rb"].each do |file|
  require_relative file
end

Dir[File.dirname(__FILE__) + "/adapters/*.rb"].each do |file|
  require_relative file
end

Dir[File.dirname(__FILE__) + "/configuration/*.rb"].each do |file|
  require_relative file
end
