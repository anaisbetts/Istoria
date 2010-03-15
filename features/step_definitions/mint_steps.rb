require 'spec/expectations' 
require 'cucumber/formatter/unicode'

$:.unshift(File.join(File.dirname(__FILE__), "..", "..", "lib"))

require 'importers/mint_importer'

Before do
  Mongo::Connection.new().db('istoria-test-mint')
  MongoMapper.database = 'istoria-test-mint'
end

After do
  Mongo::Connection.new().drop_database 'istoria-test-mint'
end

When /^I import Mint CSV into Mongo (\d+) times?$/ do |n|
  (n.to_i).times do
    @mi = MintImporter.new
    raise "Can't import!" unless @mi.can_import?(@file)
    @mi.import(@file)
  end
end

Then /^I should have (\d+) MintEvent entries$/ do |n|
  MintEvent.all.count.should == n.to_i
end
