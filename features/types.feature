
Feature: We need a basic type system to organize the data that we want to collect
	and display, that is flexible enough to be able to store all of the data
	that we're interested in.

	Scenario Outline: Loader class list
		Given we are looking for the "<ClassName>" class
		When I list the loader classes
		Then the loader class "<ClassName>" should exist

		Examples:
		| ClassName: 	|
		| Adium 	|
		| DeadJournal 	|
		| Email 	|
		| Facebook 	|
		| GVoice 	|
		| Mint  	|
		| Pidgin 	|
		| TumblrSite 	|
		| TumblrXml 	|
		| TwitterSite 	|
		| TwitterXml 	|

	Scenario: Event Type should have some properties
		Given we're loading a "Event" type fixture
		And the fixture is the "basic" fixture
		When I load the fixture
		Then the fixture should have a "content_hash" property of type "String"
		And the "content_hash" property's string length should be "64"
		And the fixture should have a "location" property of type "Array"
		And the fixture should have an "original_uri" property of type "String"
		And the fixture should have many embedded Tags
		And the fixture should have timestamps

	Scenario: Content hash should change on new tag
		Given we're loading a "Event" type fixture
		And the fixture is the "basic" fixture
		When I add a new tag
		Then the "content_hash" property should be "xxxxxxxxxx"

	Scenario: Content hash should change when a tag is removed
		Given we're loading a "Event" type fixture
		And the fixture is the "basic" fixture
		When I remove a tag
		Then the "content_hash" property should be "xxxxxxxxxx"

	Scenario: Content hash should change when custom data is added
		Given we're loading a "Event" type fixture
		And the fixture is the "custom_data" fixture
		When I set the "cool_property" to "foobar"
		Then the "content_hash" property should be "xxxxxxxxxx"

	Scenario: Timestamps should update when I change stuff
		Given we're loading a "Event" type fixture
		And the fixture is the "basic" fixture
		When I set the "cool_property" to "foobar"
		Then the "changed_on" property should be the current time
		And the "created_on" property should be "Bla bla bla bla"
