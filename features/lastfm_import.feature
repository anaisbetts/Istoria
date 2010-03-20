Feature: last.fm import
	We should be able to import last.fm data directly from the website

	Scenario: Basic functionality
		Given the last.fm user name is xpaulbettsx
		And that the last.fm limit is 2 weeks
		When I import last.fm site data into Mongo 1 time
		Then I should have more than 10 Event entries
		And every Event entry should have a Source tag
