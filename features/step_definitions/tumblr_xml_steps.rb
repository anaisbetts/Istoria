require 'spec/expectations' 
require 'cucumber/formatter/unicode'

$:.unshift(File.join(File.dirname(__FILE__), "..", "..", "lib"))

require 'importers/twitterxml_importer'

Before do
  Mongo::Connection.new().db('istoria-test-tumblrxml')
  MongoMapper.database = 'istoria-test-tumblrxml'
end

After do
  Mongo::Connection.new().drop_database 'istoria-test-tumblrxml'
end

When /^I import Tumblr XML into Mongo 1 time$/ do
    pending # express the regexp above with the code you wish you had
end

