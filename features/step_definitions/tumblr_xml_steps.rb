require 'spec/expectations' 
require 'cucumber/formatter/unicode'

$:.unshift(File.join(File.dirname(__FILE__), "..", "..", "lib"))

require 'importers/tumblrxml_importer'

After do
  Mongo::Connection.new().drop_database 'istoria-test-tumblrxml'
end

When /^I import Tumblr XML into Mongo (\d+) times?$/ do |n|
  Mongo::Connection.new().db('istoria-test-tumblrxml')
  MongoMapper.database = 'istoria-test-tumblrxml'

  (n.to_i).times do
    @ti = TumblrXmlImporter.new
    raise "Can't import!" unless @ti.can_import? @file
    @ti.import @file

    #p Message.all.map {|x| x.text}
  end
end

