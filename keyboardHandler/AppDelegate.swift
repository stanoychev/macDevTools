import Cocoa
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let hasAccessToKeys = AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary)
        
        if hasAccessToKeys == false {
            let alert = NSAlert()
            alert.messageText = "Error"
            alert.informativeText = "Application has no access to the keyboard. Try to add it to System Preferences -> Security & privacy -> Privacy -> Accesabolity / Input monitoring. In order for that to happen the application must be signed, Xcode -> Preferences -> Accounts -> [if you dont have create and] add your Apple dev account, you should automatically become also member of a Team -> Then from Xcode go to the .xcodeproj file (the top blue one) -> Signing and capabilities -> [for debug and release] select your team and signing sertificate development. Also, program must be NOT sandboxed. Just in case also go to Product -> Scheme -> Edit scheme -> Run -> Info -> Debug as -> root. If still not work restart Xcode / machine / go to google..."
            alert.addButton(withTitle: "OK")
            alert.alertStyle = NSAlert.Style.warning
            alert.runModal()
            NSApplication.shared.terminate(self)
        }
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "plus.circle", accessibilityDescription: "+")
        }
        
        constructMenu()
        keyHandler.initializeEventTap()
    }
    
    private func constructMenu() {
        let menu = NSMenu()
        menu.addItem(keyboardControl)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: ""))
        statusItem.menu = menu
    }
    
    @objc private func switchKeyboardControl() {
        enabled = !enabled
        changeStatusBarButton()
    }
    
    private func changeStatusBarButton() {
        if let button = statusItem.button {
            if enabled {
                button.image = NSImage(systemSymbolName: "plus.circle", accessibilityDescription: "+")
                keyboardControl.title = "Disable keyboard support"
            }
            else {
                button.image = NSImage(systemSymbolName: "minus.circle", accessibilityDescription: "-")
                keyboardControl.title = "Enable keyboard support"
            }
        }
    }
    
    // Assuming we have a set of images with names: statusAnimatedIcon0, ..., statusAnimatedIcon6
    //private let iconAnimation = StatusBarIconAnimationUtils()

    private var keyHandler = KeyHandler()
    private var statusItem: NSStatusItem!
    private var keyboardControl = NSMenuItem(title: "Disable keyboard support", action: #selector(switchKeyboardControl) , keyEquivalent: "")
}
