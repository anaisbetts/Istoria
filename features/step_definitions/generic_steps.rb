require 'spec/expectations' 
require 'cucumber/formatter/unicode'

Given /^I'm using the (.*) fixture$/ do |filename|
  @file = File.join(File.dirname(__FILE__), "..", "fixtures", filename)
end


##
## Event steps
##

Then /^every Event entry should have a Source tag$/ do
  Event.all.each do |x| 
    x.tags.any? {|t| t.type_sym == :source}.should == true
  end
end

Then /^every Event entry should have an original URL$/ do
  Event.all.each {|x| x.original_uri.should_not != nil}
end

Then /^(\d+) of the Events should be Geotagged$/ do |n|
  p Message.all.map {|x| x.location}
  Message.all.count {|x| not x.location.empty?}.should == n.to_i
end

Then /^the Event geotags shouldn't be garbage$/ do
  Message.all.all? {|x| x.location.empty? || (x.location.count == 2 || x.location[0] != 0.0)}.should == true
end


##
## Message steps
##

Then /^every Message entry should have text$/ do
    pending # express the regexp above with the code you wish you had
end

Then /^we should able to read the plain text of HTML Message entries$/ do
    pending # express the regexp above with the code you wish you had
end

Then /^we should able to read the plain text of Markdown Message entries$/ do
    pending # express the regexp above with the code you wish you had
end

Then /^I should have (\d+) Message entries$/ do |n|
  Message.all.count.should == n.to_i
end

Then /^every Message entry should have the format set correctly$/ do
    pending # express the regexp above with the code you wish you had
end


##
## Media Steps
##

Then /^I should have (\d+) Media entries$/ do |n|
  Media.count.should == n.to_i
end

Then /^the Media entries should have the downloaded Youtube file$/ do
    pending # express the regexp above with the code you wish you had
end

Then /^the Media entries should have the downloaded audio file$/ do
    pending # express the regexp above with the code you wish you had
end

Then /^the Media entries should have the downloaded photo$/ do
    pending # express the regexp above with the code you wish you had
end
