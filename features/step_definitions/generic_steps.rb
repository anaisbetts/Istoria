require 'spec/expectations' 
require 'cucumber/formatter/unicode'

Given /^I'm using the (.*) fixture$/ do |filename|
  @file = File.join(File.dirname(__FILE__), "..", "fixtures", filename)
end

Then /^every Event entry should have a Source tag$/ do
  Event.all.all? do |x| 
    x.tags.any? {|t| t.type_sym == :source}
  end.should == true
end
