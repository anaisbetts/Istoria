# Defines our constants
PADRINO_ENV  = ENV["PADRINO_ENV"] ||= ENV["RACK_ENV"] ||= "development" unless defined?(PADRINO_ENV)
PADRINO_ROOT = File.dirname(__FILE__) + '/..' unless defined? PADRINO_ROOT

require File.join(File.dirname(__FILE__), "..", "..", "lib", "boot")

Bundler.require(:default, PADRINO_ENV)
puts "=> Located #{Padrino.bundle} Gemfile for #{Padrino.env}"

Padrino.load!
