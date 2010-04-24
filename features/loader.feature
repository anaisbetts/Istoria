Feature: We need one place to collect all the loaders and dispatch based on them

	Scenario: We should be able to list all the loaders
		Given that I have a "LoaderCollection" as my class
		When I get the list of loaders
		Then I should get "25" items
		And the first item should have a friendly name of "Adium"
		And every item should respond to "can_import?"
		And every item should respond to "import"

	Scenario: We should be able to new up a Loader collection
		Given that I have a "LoaderCollection" as my class
		When I ask the Loader collection to refresh its loaders
		Then there should be "25" items in the Loader collection

	Scenario: The Loader collection should ignore bogus files
		Given that I have a "LoaderCollection" as my class
		When I ask the Loader collection if it can import the "__nothere" file
		Then the result should be "nil"
