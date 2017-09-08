#!/usr/bin/env ruby

require "twitter"
require 'json'
require 'pg'

conn = PG.connect( dbname: 'Trendz_development' )

client = Twitter::REST::Client.new do |config|
  config.consumer_key = 'ismn8rmArjhzt9xRkjjYsD0Bm'
  config.consumer_secret = 'YCLSCBpsQPT9F5GKqlKRBGO7EyHVvQK84VsnfQ6CEtbqfqV8Yn'
  config.access_token = '1220129761-nGIdqbvFkIOP684uH49CkMszRfmFYuUDK0tHpn4'
  config.access_token_secret = 'alCFSd3oMSU9JOLpMTM6wkTfO8CsqZIiWMh3Qc9DjbGdK'
end

Trend = Struct.new(:name, :volume)

# initialize array to hold trend information
current = Array.new

i = 0
response = client.trends(id=23424977)
response.each do |element|
  name = element['name']
  volume = element['tweet_volume']
  current[i] = Trend.new(name, volume);
  i = i + 1
end

