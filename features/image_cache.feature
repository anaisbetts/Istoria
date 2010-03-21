@fast
Feature: Image cache feature
	To store image data, we need a simple key-value storage to store off images in 
	the database that aren't actually tracked events

	Scenario Outline: Add images
		Given I'm using the <File> fixture
		When I import the image into the image cache
		Then there should be 1 ImageCache item
		And the image Mimetype should be <MimeType>

		Examples:
		| File   	| MimeType 		|
		| test.png 	| image/png 		|
		| test.jpg 	| image/jpeg 		|
