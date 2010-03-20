require 'spec/expectations' 
require 'cucumber/formatter/unicode'

$:.unshift(File.join(File.dirname(__FILE__), "..", "..", "lib"))

require 'importers/lastfm_importer'

After do
  #Mongo::Connection.new().drop_database 'istoria-test-tumblrxml'
end

Given /^the last\.fm user name is (.*)$/ do |name|
  pending # express the regexp above with the code you wish you had
end

Given /^that the last\.fm limit is (\d+) weeks$/ do |n|
  pending # express the regexp above with the code you wish you had
end

When /^I import last\.fm site data into Mongo (\d+) times?$/ do |n|
    pending # express the regexp above with the code you wish you had
end

When /^I import last\.fm XML into Mongo (\d+) times?$/ do |n|
    pending # express the regexp above with the code you wish you had
end

Then /^I should have (\d+) LastFmListen entries$/ do |n|
    pending # express the regexp above with the code you wish you had
end

Then /^all of the LastFmListen events should have play counts$/ do
  pending # express the regexp above with the code you wish you had
end
