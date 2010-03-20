require 'spec/expectations' 
require 'cucumber/formatter/unicode'

$:.unshift(File.join(File.dirname(__FILE__), "..", "..", "lib"))

When /^I import the image into the image cache$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^there should be (\d+) ImageCache items?$/ do |n|
  pending # express the regexp above with the code you wish you had
end

Then /^the image Mimetype should be (.*)$/ do |mimetype|
  pending # express the regexp above with the code you wish you had
end
