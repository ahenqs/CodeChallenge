# README #

This is an assignment as a part of a job application.

# Code Challenge #

### Libraries ###

SwityJSON library was used to parse the JSON content downloaded from web service. Therefore, Cocoapods was used to install SwiftyJSON.
PopDatePicker was a 3rd party code by Valerio Ferrucci used to improve date input.
Web service was accessed using a custom class named WebService which uses natively NSURLConnectionDataDelegate methods. Reachability was a 3rd party class to detect internet connection availability when communicating to web service. CoreData framework was used to save contacts on user’s device.

### Generating the App ###

Since this project uses Cocoapods, it’s mandatory to open the project from the CodeChallenge.xcworkspace file.

### The App ###

The app runs both on iPhones and iPads because of AutoLayout and consists basically of 3 screens grouped within a tab bar. The first tab named Contacts brings a list of all contacts. When app is started and no contacts are found, the apps asks user to download contacts from server. When user chooses to do so, contacts are downloaded to user’s device and saved to a local database through CoreData framework. When download finishes a message is shown and the list is filled. At any moment, user can add a new contact by tapping on the + sign on the right top corner of navigation bar. Also, user can edit whenever wanted or delete by tapping the Edit button on the main screen as well as change the contact photo by choosing from the Image Library on his device.

When user declines to download contacts from server, he can download contacts from the Settings tab by clicking on corresponding button. In Settings there’s also an option to delete all contacts from the device. All actions require Touch ID fingertip recognition or default password 1234.

### The Project ###

It was written in Swift 2.0 using AutoLayout and used automated tests to prevent app from eventually crashing.

### Improvements ###

I would suggest a few new features to improve the app like internationalisation, iCloud integration and better automated tests.