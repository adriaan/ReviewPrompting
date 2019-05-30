# ReviewPromping

This is a library to help you easily and thoughtfully prompt users of your app to leave a review on the App Store, by asking the right user at the right time.
The ideas behind this library (as well as a couple of case studies)  can be found [here](https://www.youtube.com/watch?v=9DI3qnbqa8o&list=PLRdg1MF7wOwyjzRyDMqNXkFhwV7tmoCki&index=13)

## What it does

It tracks the parameters that determine whether a user qualifies to be asked for a review
It presents the review prompting UI when asked to *if* the user qualifies

## Usage

Initialise `ReviewPromptingCoordinator` with a `ReviewPromptingConfiguration` and (optional) custom parameters somewhere in your `AppDelegate`'s  `application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?)`  method.
(this is important as some of the libraries' functionality depends on it receiving the `UIApplication.didFinishLaunchingNotification` )

```
let configuration = ReviewPromptingConfiguration(
    appName: "AwesomeApp", 
    shouldTriage: true, 
    isPromptingEnabled: true, 
    minDaysAfterCrash: 5, 
    minDaysAfterNegativeTriage: 10, 
    minDaysAfterPrompted: 20, 
    minDaysAfterFirstLaunch: 5, 
    minSessions: 5
)
let coordinator = ReviewPromptingCoordinator(configuration: configuration, customParameters: [], persistor: persistor, presenter: presenter)
```
### Configuration

The `ReviewPromptingCoordinator` will automically track:
- first launch date of the app
- number of sessions 
- how often a user has been prompted and when, to make sure you don't ask users too often and stay within Apple's maximum of 3 prompts a year
- when a user last responded negatively to a triage popup

The `ReviewPromptingCoordinator` has default functionality to track:
- the most recent date the app crashed (you may not want to ask a user for a review when they just experienced a crash). Crash reporters like Crashlytics offer delegate methods to tell you your app crashed in the previous session. You can use that to call `appDidCrash()` on `ReviewPromptingCoordinator`

The `ReviewPromptingCoordinator` also lets you track any custom parameters you like (as long as they are countable ones) by injecting an array of `ReviewPromptingCustomParameter` into its initialiser. For example, you may only want to prompt users that have watched certain number of videos in your app.

Set the `shouldTriage` property to `true` if you'd like to show an alert asking the user whether they enjoy using your app before showing the user Apple's rating UI. This allows you to divert any unhappy users you accidentally prompted to your customer support instead.

### Delegate callbacks

`ReviewPromptingCoordinatorDelegate` allows you to respond to feedback from the `ReviewPromptingCoordinator`, e.g. to log things to your analytics or to present your customer support UI to users who indicated they were unhappy in response to the triage alert.

