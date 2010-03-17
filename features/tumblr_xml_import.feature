Feature: Tumblr XML Import
	We should be able to import Tumblr XML data from the website

	Scenario: Basic functionality
		Given I'm using the tumblr_basic.xml fixture
		When I import Tumblr XML into Mongo 1 time
		Then I should have 50 Message entries
		And every Event entry should have an original URL
		And every Event entry should have a Source tag

	Scenario: Correct information functionality
		Given I'm using the tumblr_text.xml fixture
		When I import Tumblr XML into Mongo 1 time
		Then I should have 50 Message entries
		And every Event entry should have an original URL
		And every Event entry should have a Source tag
		And every Message entry should have text
		And every Message entry should have the format set correctly
		And we should able to read the plain text of HTML Message entries
		And we should able to read the plain text of Markdown Message entries

	Scenario: Youtube import
		Given I'm using the tumblr_youtube.xml fixture
		When I import Tumblr XML into Mongo 1 time
		Then I should have 50 Media entries
		And the Media entries should have the downloaded Youtube file

	Scenario: Audio import
		Given I'm using the tumblr_youtube.xml fixture
		When I import Tumblr XML into Mongo 1 time
		Then I should have 50 Media entries
		And the Media entries should have the downloaded audio file

	Scenario: Photo import
		Given I'm using the tumblr_photo.xml fixture
		When I import Tumblr XML into Mongo 1 time
		Then I should have 50 Media entries
		And the Media entries should have the downloaded photo

	Scenario: Duplicate detection
		Given I'm using the tumblr_basic.xml fixture
		When I import Tumblr XML into Mongo 2 times
		Then I should have 20 Message entries
