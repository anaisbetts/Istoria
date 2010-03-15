Feature: Twitter Import
	We should be able to import Twitter data directly from the website

	Scenario: Basic functionality
		Given the Twitter user name is xpaulbettsx
		And that the Twitter limit is 4 pages
		When I import Twitter site data into Mongo 1 time
		Then I should have 79 Message entries
		And some of the Messages should be Geotagged
		And the Message geotags shouldn't be garbage
		And every Event entry should have a Source tag
