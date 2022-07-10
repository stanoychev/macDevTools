import Cocoa

var enabled: Bool = true
//follow value orders!! the order in the all = [#1, #2, #3 ...]
let all : Array<CGEventFlags> = [.maskAlphaShift, .maskShift, .maskControl, .maskAlternate, .maskCommand, .maskHelp, .maskSecondaryFn, .maskNumericPad, .maskNonCoalesced]

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
                    for flag in all {
                        if event.flags.contains(flag) {
                            eventFlagsAsCollection.append(flag)
                        }
                    }
                    
                    let key16 :UInt16 = UInt16(event.getIntegerValueField(.keyboardEventKeycode))
                    
                    if type == .otherMouseDown {
                        let click16 = UInt16(event.getIntegerValueField(.mouseEventButtonNumber))
                        
                        //navigate back in Finder
                        if click16 == MouseButton.back
                            && NSWorkspace.shared.frontmostApplication?.localizedName == "Finder" {
                            FakeKey.sendOne(Keycode.upArrow, [.maskCommand, .maskSecondaryFn, .maskNumericPad, .maskNonCoalesced])
                            return nil
                        }
                        
                        //navigate forward in Finder
                        if click16 == MouseButton.next
                            && NSWorkspace.shared.frontmostApplication?.localizedName == "Finder" {
                            FakeKey.sendOne(Keycode.downArrow, [.maskCommand, .maskSecondaryFn, .maskNumericPad, .maskNonCoalesced])
                            return nil
                        }
                    } else if type == .keyDown {
                        
                        //ctrl + c/v/x a/s/z/f
                        if [Keycode.c, Keycode.v, Keycode.x, Keycode.a, Keycode.s, Keycode.z, Keycode.f].contains(key16)
                            && eventFlagsAsCollection == [.maskControl, .maskNonCoalesced] {
                            event.flags.remove(.maskControl)
                            event.flags.insert(.maskCommand)
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
                        }
                        
                        if NSWorkspace.shared.frontmostApplication?.localizedName == "Finder" {
                            //navigate back in Finder
                            if key16 == Keycode.delete && eventFlagsAsCollection == [.maskNonCoalesced] {
                                FakeKey.sendOne(Keycode.upArrow, [.maskCommand, .maskSecondaryFn, .maskNumericPad, .maskNonCoalesced])
                                return nil
                            }
                            
                            //delete file or folder in Finder
                            if key16 == Keycode.forwardDelete && eventFlagsAsCollection == [.maskSecondaryFn, .maskNonCoalesced] {
                                FakeKey.sendOne(Keycode.delete, [.maskCommand, .maskNonCoalesced])
                                return nil
                            }
                            
                            //open folder in Finder with Enter
                            if key16 == Keycode.returnKey && eventFlagsAsCollection == [.maskNonCoalesced] {
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
                        
                        //ctrl + arrow
                        if [Keycode.leftArrow, Keycode.rightArrow].contains(key16)
                            && (eventFlagsAsCollection == [.maskControl, .maskSecondaryFn, .maskNumericPad, .maskNonCoalesced]
                                //ctrl + shift + arrow (for text selection)
                                || eventFlagsAsCollection == [.maskShift, .maskControl, .maskSecondaryFn, .maskNumericPad, .maskNonCoalesced]) {
                                event.flags.remove(.maskControl)
                                event.flags.insert(.maskAlternate)
                        }
                        
                        //home
                        if key16 == Keycode.home {
                            //home to go to most left on the row
                            if eventFlagsAsCollection == [.maskSecondaryFn, .maskNonCoalesced] {
                                event.setIntegerValueField(.keyboardEventKeycode, value: (Keycode.leftArrow as NSNumber).int64Value)
                                event.flags.insert(.maskCommand)
                            //home + shift for text selection
                            } else if eventFlagsAsCollection == [.maskShift, .maskSecondaryFn, .maskNonCoalesced] {
                                event.setIntegerValueField(.keyboardEventKeycode, value: (Keycode.leftArrow as NSNumber).int64Value)
                                event.flags.insert(.maskCommand)
                            }
                        }
                        
                        //end
                        if key16 == Keycode.end {
                            //end to go to most right on the row
                            if eventFlagsAsCollection == [.maskSecondaryFn, .maskNonCoalesced] {
                                event.setIntegerValueField(.keyboardEventKeycode, value: (Keycode.rightArrow as NSNumber).int64Value)
                                event.flags.insert(.maskCommand)
                            //end + shift for text selection
                            } else if eventFlagsAsCollection == [.maskShift, .maskSecondaryFn, .maskNonCoalesced] {
                                event.setIntegerValueField(.keyboardEventKeycode, value: (Keycode.rightArrow as NSNumber).int64Value)
                                event.flags.insert(.maskCommand)
                            }
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
