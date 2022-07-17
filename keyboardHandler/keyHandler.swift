import Cocoa

var enabled: Bool = true
//when comparing collections follow value orders!! OK = [#1, #3, #7] / not OK = [#4, #2, #6]
let all : Array<CGEventFlags> = [.maskAlphaShift, .maskShift, .maskControl, .maskAlternate, .maskCommand, .maskHelp, .maskSecondaryFn, .maskNumericPad, .maskNonCoalesced]
let allWithoutCapsLock : Array<CGEventFlags> = [.maskShift, .maskControl, .maskAlternate, .maskCommand, .maskHelp, .maskSecondaryFn, .maskNumericPad, .maskNonCoalesced]
let commonKeys = [Keycode.c, Keycode.v, Keycode.x, Keycode.a, Keycode.s, Keycode.z, Keycode.f]

class KeyHandler: NSView {
    func initializeEventTap() {
        let eventTap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: 1 << CGEventType.keyDown.rawValue | 1 << CGEventType.flagsChanged.rawValue | 1 << CGEventType.otherMouseDown.rawValue,
            callback: {
                (_, type, event, _) -> Unmanaged<CGEvent>? in event
                if enabled {
                    var eventFlagsAsCollection : Array<CGEventFlags> = []
                    for flag in allWithoutCapsLock { //use allWithoutCapsLock to make the program caps lock agnostic
                        if event.flags.contains(flag) {
                            eventFlagsAsCollection.append(flag)
                        }
                    }
                    
                    let key16 :UInt16 = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
                    let processName = NSWorkspace.shared.frontmostApplication?.localizedName
                    
                    if type == .otherMouseDown {
                        let click16 = UInt16(event.getIntegerValueField(.mouseEventButtonNumber))
                        
                        //navigate back in Finder
                        if click16 == MouseButton.back
                            && processName == "Finder" {
                            FakeKey.sendOne(Keycode.upArrow, [.maskCommand, .maskSecondaryFn, .maskNumericPad, .maskNonCoalesced])
                            return nil
                        }
                        
                        //navigate forward in Finder
                        if click16 == MouseButton.next
                            && processName == "Finder" {
                            FakeKey.sendOne(Keycode.downArrow, [.maskCommand, .maskSecondaryFn, .maskNumericPad, .maskNonCoalesced])
                            return nil
                        }
                    } else if type == .keyDown {
                        if key16 == Keycode.w
                            && processName == "Firefox"
                            && eventFlagsAsCollection == [.maskControl, .maskNonCoalesced] {
                                event.flags.remove(.maskControl)
                                event.flags.insert(.maskCommand)
                                return Unmanaged.passRetained(event)
                        }
                        
                        //ctrl + c/v/x a/s/z/f
                        if commonKeys.contains(key16)
                            && eventFlagsAsCollection == [.maskControl, .maskNonCoalesced] {
                            event.flags.remove(.maskControl)
                            event.flags.insert(.maskCommand)
                            return Unmanaged.passRetained(event)
                        }
                        
                        //win + D = show desktop
                        if key16 == Keycode.d && eventFlagsAsCollection == [.maskAlternate, .maskNonCoalesced] {
                            FakeKey.sendOne(103, [.maskSecondaryFn, .maskNonCoalesced])
                            return nil
                        }
                        
                        //win + E = open finder
                        if key16 == Keycode.e && eventFlagsAsCollection == [.maskAlternate, .maskNonCoalesced] {
                            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: "/Users/nikolastanoychev")
                            return nil
                        }
                        
                        //ctrl + y (redo)
                        if Keycode.y == key16 && eventFlagsAsCollection == [.maskControl, .maskNonCoalesced] {
                            event.flags.remove(.maskControl)
                            event.flags.insert(.maskCommand)
                            event.flags.insert(.maskShift)
                            event.setIntegerValueField(.keyboardEventKeycode, value: (Keycode.z as NSNumber).int64Value)
                            return Unmanaged.passRetained(event)
                        }
                        
                        //TODOs interact more inteligently with Finder process, rather than resending key combinations
                        if processName == "Finder" {
                            //navigate back in Finder
                            if false // !!!!! CONFLICTS ON FILE RENAME
                                && key16 == Keycode.delete && eventFlagsAsCollection == [.maskNonCoalesced] {
                                FakeKey.sendOne(Keycode.upArrow, [.maskCommand, .maskSecondaryFn, .maskNumericPad, .maskNonCoalesced])
                                return nil
                            }
                            
                            //delete file or folder in Finder
                            if false // !!!!! CONFLICTS ON FILE RENAME
                                && key16 == Keycode.forwardDelete && eventFlagsAsCollection == [.maskSecondaryFn, .maskNonCoalesced] {
                                FakeKey.sendOne(Keycode.delete, [.maskCommand, .maskNonCoalesced])
                                return nil
                            }
                            
                            //open folder in Finder with Enter
                            if false // !!!!! CONFLICTS ON FILE RENAME
                                && key16 == Keycode.returnKey && eventFlagsAsCollection == [.maskNonCoalesced] {
                                FakeKey.sendOne(Keycode.o, [.maskCommand, .maskNonCoalesced])
                                return nil
                            }
                            
                            //rename file or folder with F2
                            if key16 == Keycode.f2 && eventFlagsAsCollection == [.maskSecondaryFn, .maskNonCoalesced] {
                                event.setIntegerValueField(.keyboardEventKeycode, value: (Keycode.returnKey as NSNumber).int64Value)
                                event.flags.remove(.maskSecondaryFn)
                            }
                            
                            return Unmanaged.passRetained(event)
                        }
                        
                        
                        /*           The code is below Finder, because is text processing related,          //
                        //      so if we are in Finder there is no need for the instructions to get here    //
                        //                                                                                  //
                        //                                                                                  */
                        
                        //ctrl + arrow
                        if [Keycode.leftArrow, Keycode.rightArrow].contains(key16)
                            && (eventFlagsAsCollection == [.maskControl, .maskSecondaryFn, .maskNumericPad, .maskNonCoalesced]
                                //ctrl + shift + arrow (for text selection)
                                || eventFlagsAsCollection == [.maskShift, .maskControl, .maskSecondaryFn, .maskNumericPad, .maskNonCoalesced]) {
                            event.flags.remove(.maskControl)
                            event.flags.insert(.maskAlternate)
                            return Unmanaged.passRetained(event)
                        }
                        
                        //home
                        if key16 == Keycode.home
                            //home to go to most left on the row
                            && (eventFlagsAsCollection == [.maskSecondaryFn, .maskNonCoalesced]
                                //home + shift for text selection
                                || eventFlagsAsCollection == [.maskShift, .maskSecondaryFn, .maskNonCoalesced]) {
                            event.setIntegerValueField(.keyboardEventKeycode, value: (Keycode.leftArrow as NSNumber).int64Value)
                            event.flags.insert(.maskCommand)
                            return Unmanaged.passRetained(event)
                        }
                        
                        //end
                        if key16 == Keycode.end
                            //end to go to most right on the row
                            && (eventFlagsAsCollection == [.maskSecondaryFn, .maskNonCoalesced]
                                //end + shift for text selection
                                || eventFlagsAsCollection == [.maskShift, .maskSecondaryFn, .maskNonCoalesced]) {
                            event.setIntegerValueField(.keyboardEventKeycode, value: (Keycode.rightArrow as NSNumber).int64Value)
                            event.flags.insert(.maskCommand)
                            return Unmanaged.passRetained(event)
                        }
                        
                    } else if type == .flagsChanged {
                        //switch keyboard language
                        if eventFlagsAsCollection == [.maskShift, .maskCommand, .maskNonCoalesced] {
                            FakeKey.sendOne(Keycode.space, [.maskControl, .maskNonCoalesced])
                            return nil
                        }
                    }
                }
                
                return Unmanaged.passRetained(event)
            },
            userInfo: nil)
    
        CFRunLoopAddSource(
            RunLoop.current.getCFRunLoop(),
            CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap!, 0),
            CFRunLoopMode.defaultMode)
    }
}

class FakeKey {
    static func launchLaunchpad() {
        let f4Down = CGEvent(keyboardEventSource: nil, virtualKey: 131, keyDown: true)
        let f4Up = CGEvent(keyboardEventSource: nil, virtualKey: 131, keyDown: false)

        f4Down?.flags = [.maskSecondaryFn, .maskNonCoalesced]

        f4Down?.post(tap: .cghidEventTap)
        f4Up?.post(tap: .cghidEventTap)

        CGEvent.init(source: nil)?.post(tap: .cghidEventTap)
        //FakeKey.sendOne(131, [.maskSecondaryFn, .maskNonCoalesced])
    }
    
    static func sendOne(_ key: uint16, _ flags: CGEventFlags) {
        let keyDown = CGEvent(keyboardEventSource: nil, virtualKey: key, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: nil, virtualKey: key, keyDown: false)

        keyDown?.flags = flags

        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)

        CGEvent.init(source: nil)?.post(tap: .cghidEventTap)
    }
}

struct MouseButton {
    static let middle   : UInt16 = 0x02
    static let back     : UInt16 = 0x03
    static let next     : UInt16 = 0x04
}
