import AppKit
import Testing
@testable import cleaning_mode

@MainActor
struct KeyboardLockTests {
    @Test func swallowsKeysAndCountsRealPresses() {
        let lock = KeyboardLock()
        let down = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: true)!
        let up = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: false)!
        let held = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: true)!
        held.setIntegerValueField(.keyboardEventAutorepeat, value: 1)

        #expect(lock.handle(.keyDown, down) == nil)
        #expect(lock.handle(.keyUp, up) == nil)
        #expect(lock.handle(.keyDown, held) == nil)
        #expect(lock.handle(.flagsChanged, up) == nil)
        #expect(lock.blockedPresses == 1)
    }

    @Test func swallowsMediaKeys() {
        let lock = KeyboardLock()
        func media(_ state: Int) -> CGEvent {
            NSEvent.otherEvent(with: .systemDefined, location: .zero, modifierFlags: [], timestamp: 0,
                               windowNumber: 0, context: nil, subtype: 8,
                               data1: (0 << 16) | (state << 8), data2: -1)!.cgEvent!
        }
        let type = CGEventType(rawValue: 14)!
        #expect(lock.handle(type, media(0xA)) == nil)
        #expect(lock.handle(type, media(0xB)) == nil)
        #expect(lock.blockedPresses == 1)
    }

    @Test func letsMouseThrough() {
        let lock = KeyboardLock()
        let click = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown,
                            mouseCursorPosition: .zero, mouseButton: .left)!
        #expect(lock.handle(.leftMouseDown, click) != nil)
        #expect(lock.blockedPresses == 0)
    }
}
