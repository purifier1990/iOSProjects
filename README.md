# Retrospective

Based on the requirement, I have chosen MVVM pattern as VIPER is kind of over kill for this app. As for the choice of language, although I could write in Objective-C, I've been using Swift to do iOS development and I believe Swift should be the best option.

# Architechture

* The minimum requirements include two UI views, and some network processes, in order to make Unit test easy to write, the architechture should seperate different logics into different parts, so after taking some time to think about the structure, I have didived them into 3 parts, which are UI layer, relative viewModel layer and networking layer.
    * UI layer, which is known as View layer for MVVM, basically it will include all the UI element interaction logic, like tableView dataSource, delegate, button tap action, and its like.
    * ViewModel layer, so this layer is mainly set based on the patter, as MVVM can avoid big viewController issue for old MVC pattern, for UT, this MVVM pattern can easily test them seperately, so viewModel will include model for this view, and will be initialized by dependency injection before load view itself. ViewModel layer is like a bridge, when UI modifies model, viewModel will know, and when viewModel are modified by networking reponse, model will let view know and do the UI update.
    * Networking layer, which is a networking request wrapper, as I am not allowed to pull the 3rd party library like Alamofire, so I did a small wrapper which only has the get request handler, and other mock post/get handlers for direct message.

# Implement details

This part will describe the details about each part including stuffs not mentioned above such as model and additional enhanced part like data persistence.
The project structure is shown below:
```
DM
├── CoreData
|     ├── cacheChatHistory.xcdatamodeld
|     ├── CacheChatHistory.swift
|     └── CacheMessage.swift  
├── Utils
|     ├── Constants.swift
|     └── UIViewController+LargeTitleDisplayMode.swift
├── Network
|     ├── NetworkService.swift
|     ├── ServiceManager.swift
|     └── MockChatHistoryResponse.swift
├── Resources
|     ├── Main.storyboard
|     └── Assets.xcassets
├── Features
|     ├── DirectMessage
|     |         ├── DirectMessageViewController.swift
|     |         ├── DirectMessageViewModel.swift
|     |         ├── DirectMessageCell.swift
|     |         └── Message.swift
|     └── TeammateList
|               ├── TeammateListViewController.swift
|               ├── TeammateCell.swift
|               ├── Teammate.swift
|               └── TeammateListViewModel.swift
├── SceneDelegate.swift
├── AppDelegate.swift
├── LaunchScreen.storyboard
└── Info.plist
```

### Features

This directories are this app's core directories which includes two UI view, TeammateList view and DirectMessage view.

* TeammateList
    * TeammateListViewController.swift, controller logic, including a dependency injection class method, configure navigation bar title to make it align with spec, change default tableView separoter to make it align with spec, spinner rolling before the async calling "GET Users" API to get teammate list comes back and stops rolling when viewModel updates. DataSoure not trick inside, Delegate has dependency injection for the directMessage viewController. Its own delegate provides two callbacks for viewModel to notify view to update UI when models changes, one is to handle "GET Users" API success and load UI, the other is to handle two API error scenarios, which are normal error and rate limit error, both will show an alert but with different error messages.
    * TeammateCell.swift, UI cell logic, main logic is calling an async API to load avatar image and refresh when it's ready to display, otherwise, display a placeholder image.
    * Teammate.swift, model logic, nothing special, just use Postman to get the API response and make it here, then use Codable to automatically decode response.
    * TeammateListViewModel.swift, viewModel logic, model property which will need to notify View to update UI has enabled didSet method to call the delegate callback to update UI, nothing special, one point to care for is that background API comes back needs to dispatch to main thread.
* DirectMessage
    * DirectMessageViewController.swift, controller logic, follow the same pattern with TeammateListViewController, something special in this controller has 4 parts
        * Polling. The requirement has mentioned to use mock post/get to handle chat, that gives me a hint to use polling for this scenario, view send a get API per second to try to fetch the latest chat messages, and update UI. Polling starts when view loads and stops when view disappear.
        * Keyboard. When the keyboard pops up, if no logic for this action, textfield will be overlapped with keyboard, which is not user-friendly, so adding some logic to move view up when keyboard shows, and restore when it disappears, also add gesture when user taps somewhere not inside the keyboard, dismiss the keyboard.
        * Update tableView. Compared with TeammateList's tableView, which is one time update, so calling "reloadData()" is OK, but for this view, as the tableView is updating frequently, so calling that heavy API will cost CPU enegy and the UI will not look consitent, so intead of reloading them all, only update the different part compared with previous dataSource.
        * Data Persistence. As an additional request, I added this support by introducing CoreData, save the chat history when view disappear and load them from disk when view appears, might be naive code as I just learnt to use them.
    * DirectMessageViewModel.swift, viewModel logic, follow the same pattern with TeammateListViewModel, one special function is to generate different part of chat messages between current polled latest messages and last messages by comparing message texts.
    * DirectMessageCell.swift, follow the same patter with TeammateCell, one special difference is to dynamically update constraints based on sent message or received message as they has different position from view.
    * Message.swift, a simple model for saving chat messages, as generating diff message will need to comapre each message, so additionaly implement the protocol Equatable.

### Network

This directories implement all the networking API wrapper and mock ones.

* NetworkService.swift. By using native Result type, and define specific networking API error enum, very clean and neat finished this wrapper class, one thing to notice, rate limit error has been triggered and see what response for this error will be and handled it seperately.

* MockChatHistoryResponse.swift. As the file name says, it's just a mock service, by storing the mesages into a dict and hanlde GET, and when it's POST, copy the message twice and save it as a response message.

* ServiceManager.swift. This is a upper class for NetworkService, it's a singleton pattern as this would be easy to write Unit test, and can be easily merged into viewModel. It also implements the mock POST/GET API wrapper for chat.

### Resources

This directories use Assets and Storyboard to draw all the needed UI.

* Main.storyboard, settle down all the UI elements, assign relative outlet, action, constraint and so on to make App can run under both landscape and portrait mode.
* Asstes, pull the given pictures into this assets, added a placeholder image for avatar, using slice feature to modify bubble background and appIcon for it can be updated to TestFlight

### Utils

This directories mainly keep some Extention and Constant.

* UIViewController+LargeTitleDisplayMode.swift, to implement the required big navigation title style, I changed some property but found there will be a animation failed bug, so after some research, I finally found this extention solution will solve that animation failed bug(keep navigation title into big style and push view into message view, the title will stay at message view for a second, then disappear)

* Constants.swift, save some constant value to make it easy to be referenced and modified later

### CoreData

This directories implement the data persistence logic with CoreData.

* cacheChatHistory.xcdatamodeld, CoraData model, as CoreData can't save dictionary directly, so use 'transformable' to give it a custom class.

* CacheChatHistory.swift, Dictionary class used by CoreData model.

* CacheMessage.swift, bridge class for model Message to CoreData saved Message.

# Some improvements I wanted to do but not enough time

* Unit test, obvious unit test is needed for app, that will make devOps possible.
* Message diff generate logic should be best based on timestamp, as messages can be the same sometimes. Also, with timestamp involved, messages can be sectioned with a data period.
* Design mock service of GET, it can be based on timestamp to save bandwidth of server in the real world.
* Chat message app should not be focused only with current teammate, it should be able to listen to others' chat response and display hint in the main page.
* Notification for each received message.
* Sounds for sending and receiving messages.
* Network health check on the navigation bar title to indicate user if it's connected, for the real world, each sent message might not be directly sent to server, it might take some delay, so some spiner will be needed.
* Receicer's status might be needed to indicate if he/she is typing something or not or received
* 3D touch for messages, like IMessage, we can copy/paste/forward or anything else to make chat easily

# Known issues

* In DirectMessage View, if polling result and send message action happens at the same time, tableView will have a quick joggle, that's because the mock POST/GET APIs actually have very few delay, so the send message and polling result might come to App in a short time slot, so the dataSource of tableView will be updated in a short very short time twice, and caused the issue. In a real world, it could not happen.

* When showing an empty view for DirectMessage View, if user pops up keyboard, and send some message, as view has been moved up a little bit, so the first message might not be seen till the keyboard disappears. Based on current implement, this issue can't be resolved, it would need more code to handle this corner case.

* When app running under landscape mode, for the TeammateList view, the seperator might not look well adapted to the UI.

# Build enviroment

Xcode 11.3.1
Swift 5.1

# TestFlight

If anything unexpected happens, you may try a TestFlight beta app to have a try, please send an email to purifier1990@gmail.com including your Apple ID and I can add you into this app's Test group, thanks!

    