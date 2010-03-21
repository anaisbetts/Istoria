@fast @twitter @import
Feature: Twitter XML Import
	We should be able to import Twitter XML data from the website

	Scenario: Basic functionality
		Given I'm using the twitter_basic.xml fixture
		When I import Twitter XML into Mongo 1 time
		Then I should have 20 Message entries
		And every Event entry should have an original URL
		And every Event entry should have a Source tag
		And 1 of the Events should be Geotagged
		And the Event geotags shouldn't be garbage

	Scenario: Duplicate detection
		Given I'm using the twitter_basic.xml fixture
		When I import Twitter XML into Mongo 2 times
		Then I should have 20 Message entries
