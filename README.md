# macDevTools
Background app assisting with local development tasks

# Windows keyboard shortcuts on mac OS
The application intercepts key stroke events on low level, if they are of interest modifies them and then they continue up the chain, reaching the focused application.

For example, if you press "Control + C", the event args are modified and it becomes "Command + C", issuing a copy command.

Problems this solves:
Limitations: I wanted to change System preferences -> keyboard -> "Input sources" to switch with "Command + Shift", but this is not allowed.
Flexibility: For example, it is made that "Control + W" is intercepted only in Firefox (to close the current tab), thuss not affecting this key combination in other applications.

Problems it creates:
Of course, the pressed buttons combination can invoke something unexpected.

Code quality and performance:
This is my "Hello swift and Xcode" application, so I don't know the language tricks and ugly code is present, like the global variables.
I wanted the code to be easiest posssible for reading, understanding and modification by total swift noobs like me.
Finally, because we attach a bunch of logic on every key stroke, which is relatively frequent operation, the code is attempted to be fast.

How to run:
For now this is ment to be build and run locally.
1. Get Xcode from apple store
2. Git clone the repository and open it in with Xcode
3. Build and run the app. You'll get an error message, because we need to run it as root and/or give permissions to the keyboard events. To be honest I don't remember how exactly I enabled it. Don't worry, the procedure is very easy and intuitive, as of Jul 2022 you just have to:
	- NOT RUN XCODE AS ROOT, causes pain
	- (if you don't have) create developer.apple.com account
	- Then, go to -> Xcode -> Preferences -> Accounts -> bottom left click the "+" -> add the above mentioned account. It will automaticaly assign you in team (Personal Team)
	- Naturally, click the .xcodeproj file (blue one) -> Signing and capabilities -> Team: the team from above; Signing certificates: Development
	- Of course, we continue by -> Xcode -> Product -> Scheme -> Edit scheme -> Run -> Info -> Debug Process as -> switch to root
	- Finally -> System preferences -> Security and privacy -> Privacy -> Because 
		1) I'm not sure which one and
		2) in the long term this application will mutate as local machine assisting dev tool
		I added the application in "Accessability", "Input monitoring", "Full disk access", "Files and folders", "Developer tools". It's super intuitive where the built file, that you have to select, is located. Of course not your git folder, rather /Users/[you]/Library/Developer/Xcode/DerivedData/devTools-[some GUID]/Build/Products/Debug/keyboardHandler.app (Bare in mind, in future the app name might change, once I understand how to do it without braking the whole project.)
	- More finally, build and run the program. Instead of error, this time you should be ambushed with passowrd/fingerprint request. If everithing is fine a circle with "+" in it should appear on the top bar.