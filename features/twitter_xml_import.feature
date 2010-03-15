Feature: Twitter XML Import
	We should be able to import Twitter XML data from the website

	Scenario: Basic functionality
		Given I'm using the twitter_basic.xml fixture
		When I import Twitter XML into Mongo 1 time
		Then I should have 20 Message entries

	Scenario: Duplicate detection
		Given I'm using the twitter_basic.xml fixture
		When I import Twitter XML into Mongo 2 times
		Then I should have 20 Message entries
		And 1 of the Messages should be Geotagged
		And the Message geotags shouldn't be garbage
		And every Event entry should have a Source tag
