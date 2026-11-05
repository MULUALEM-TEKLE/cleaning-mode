import AppKit
import Combine

/// Swallows every key press while the keyboard is being cleaned.
final class KeyboardLock: ObservableObject {
    @Published private(set) var isLocked = false
    @Published private(set) var isTrusted = AXIsProcessTrusted()
    @Published private(set) var blockedPresses = 0
    @Published private(set) var endDate = Date()
    @Published private(set) var error: String?

    private var tap: CFMachPort?
    private var source: CFRunLoopSource?
    private var timer: Timer?
    private let overlay = Overlay()

    /// Media and brightness keys arrive as NX_SYSDEFINED events.
    private static let systemDefined = CGEventType(rawValue: 14)!

    func refreshTrust() { isTrusted = AXIsProcessTrusted() }

    func requestAccess() {
        let prompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        AXIsProcessTrustedWithOptions([prompt: true] as CFDictionary)
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            MainActor.assumeIsolated {
                self?.refreshTrust()
                if self?.isTrusted != false { timer.invalidate() }
            }
        }
    }

    func lock(for seconds: TimeInterval) {
        guard !isLocked else { return }
        error = nil
        refreshTrust()
        guard isTrusted else { return requestAccess() }

        let mask = [CGEventType.keyDown, .keyUp, .flagsChanged, Self.systemDefined]
            .reduce(CGEventMask(0)) { $0 | 1 << $1.rawValue }
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: { _, type, event, refcon in
                let lock = Unmanaged<KeyboardLock>.fromOpaque(refcon!).takeUnretainedValue()
                return MainActor.assumeIsolated { lock.handle(type, event) }
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            error = "macOS refused the keyboard lock. In System Settings › Privacy & Security › Accessibility, turn Cleaning Mode off and on again."
            return
        }

        self.tap = tap
        source = CFMachPortCreateRunLoopSource(nil, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)

        blockedPresses = 0
        endDate = Date().addingTimeInterval(seconds)
        timer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false) { [weak self] _ in
            MainActor.assumeIsolated { self?.unlock() }
        }
        isLocked = true
        overlay.show(self)
    }

    func unlock() {
        guard isLocked else { return }
        timer?.invalidate()
        if let tap {
            CGEvent.tapEnable(tap: tap, enable: false)
            CFMachPortInvalidate(tap)
        }
        if let source { CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes) }
        timer = nil
        tap = nil
        source = nil
        isLocked = false
        overlay.hide()
    }

    /// The event tap's verdict: nil swallows the event.
    func handle(_ type: CGEventType, _ event: CGEvent) -> Unmanaged<CGEvent>? {
        switch type {
        case .tapDisabledByTimeout, .tapDisabledByUserInput:
            if let tap { CGEvent.tapEnable(tap: tap, enable: true) }
        case .keyDown:
            if event.getIntegerValueField(.keyboardEventAutorepeat) == 0 { blockedPresses += 1 }
            return nil
        case .keyUp, .flagsChanged:
            return nil
        case Self.systemDefined:
            // Subtype 8 is the aux control buttons: volume, brightness, play, etc.
            guard let ns = NSEvent(cgEvent: event), ns.subtype.rawValue == 8 else { break }
            if (ns.data1 & 0xFF00) >> 8 == 0xA { blockedPresses += 1 }
            return nil
        default:
            break
        }
        return Unmanaged.passUnretained(event)
    }
}
