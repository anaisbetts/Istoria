require 'spec/expectations' 
require 'cucumber/formatter/unicode'

$:.unshift(File.join(File.dirname(__FILE__), "..", "..", "lib"))

require 'importers/twitter_importer'

Before do
  Mongo::Connection.new().db('istoria-test-twitter')
  MongoMapper.database = 'istoria-test-twitter'
end

After do
  Mongo::Connection.new().drop_database 'istoria-test-twitter'
end

Given /^the Twitter user name is (\w+)$/ do |name|
  @name = name
end

Given /^that the Twitter limit is (\d+) pages?$/ do |n|
  @limit = n.to_i
end

When /^I import Twitter site data into Mongo (\d+) times?$/ do |n|
  return
  (n.to_i).times do
    @ti = TwitterImporter.new(:limit => @limit)
    raise "Can't import!" unless @ti.can_import? @name
    @ti.import @name
  end
end

Then /^some of the Messages should be Geotagged$/ do
  Message.all.count {|x| x.location}.should > 2
end
