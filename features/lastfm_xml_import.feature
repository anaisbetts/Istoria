@fast @lastfm @import
Feature: last.fm XML Import
	We should be able to import one week's worth of data from a fixture

	Scenario: Basic functionality
		Given I'm using the lastfm_basic.xml fixture
		When I import last.fm XML into Mongo 1 time
		Then I should have 13 LastFmListen entries
		And all of the LastFmListen events should have play counts
		And I should have 11 FileCache items

	Scenario: Duplicate detection
		Given I'm using the lastfm_basic.xml fixture
		When I import last.fm XML into Mongo 2 times
		Then I should have 13 LastFmListen entries
		And I should have 11 FileCache items
