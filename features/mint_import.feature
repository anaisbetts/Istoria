@fast @mint @import
Feature: Mint Import
	We should be able to import Mint data from the website

	Scenario: Basic functionality
		Given I'm using the mint_basic.csv fixture
		When I import Mint CSV into Mongo 1 time
		Then I should have 92 MintEvent entries
		And every Event entry should have a Source tag

	Scenario: Duplicate detection
		Given I'm using the mint_basic.csv fixture
		When I import Mint CSV into Mongo 2 times
		Then I should have 92 MintEvent entries
