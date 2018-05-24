require 'yaml'
require './lib/start'
require 'pry'

config = YAML.load_file(ARGV.first || 'config.yml')

atm = StartAtm.new(config)

atm.start
