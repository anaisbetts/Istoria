Feature: last.fml XML Import
	We should be able to import one week's worth of data from a fixture

	Scenario: Basic functionality
		Given I'm using the lastfm_basic.xml fixture
		When I import last.fm XML into Mongo 1 time
		Then I should have 20 LastFmListen entries
		And all of the LastFmListen events should have play counts

	Scenario: Duplicate detection
		Given I'm using the lastfm_basic.xml fixture
		When I import last.fm XML into Mongo 2 times
		Then I should have 20 LastFmListen entries
