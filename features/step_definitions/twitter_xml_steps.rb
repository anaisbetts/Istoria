require 'spec/expectations' 
require 'cucumber/formatter/unicode'

$:.unshift(File.join(File.dirname(__FILE__), "..", "..", "lib"))

require 'importers/twitterxml_importer'

Before do
  Mongo::Connection.new().db('istoria-test-twitterxml')
  MongoMapper.database = 'istoria-test-twitterxml'
end

After do
  Mongo::Connection.new().drop_database 'istoria-test-twitterxml'
end

When /^I import Twitter XML into Mongo (\d+) times?$/ do |n|
  (n.to_i).times do
    @ti = TwitterXmlImporter.new
    raise "Can't import!" unless @ti.can_import? @file
    @ti.import @file
  end
end

Then /^I should have (\d+) Message entries$/ do |n|
  Message.all.count.should == n.to_i
end

Then /^(\d+) of the Messages should be Geotagged$/ do |n|
  p Message.all.map {|x| x.location}
  Message.all.count {|x| not x.location.empty?}.should == n.to_i
end

Then /^the Message geotags shouldn't be garbage$/ do
  Message.all.all? {|x| x.location.empty? || (x.location.count == 2 || x.location[0] != 0.0)}.should == true
end
