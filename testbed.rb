require './lib/stegodon/base'
require './lib/stegodon/configuration'
require './lib/stegodon/dsl'
require 'awesome_print'

Stegadon::Configuration.new(:default) do
  host 'localhost'
  username 'postgres'
  password 'gibberish'
end

Stegadon::Backup.new do
  configuration :default

  database "exchange_development"
  location "./"
end

