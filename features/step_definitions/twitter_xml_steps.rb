require 'spec/expectations' 
require 'cucumber/formatter/unicode'

$:.unshift(File.join(File.dirname(__FILE__), "..", "..", "lib"))

require 'importers/twitterxml_importer'

After do
  Mongo::Connection.new().drop_database 'istoria-test-twitterxml'
end

When /^I import Twitter XML into Mongo (\d+) times?$/ do |n|
  Mongo::Connection.new().db('istoria-test-twitterxml')
  MongoMapper.database = 'istoria-test-twitterxml'

  (n.to_i).times do
    @ti = TwitterXmlImporter.new
    raise "Can't import!" unless @ti.can_import? @file
    @ti.import @file
  end
end
