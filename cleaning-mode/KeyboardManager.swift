import Foundation
import AppKit
import Carbon
import Combine

class KeyboardManager: ObservableObject {
    @Published var isCleaningModeEnabled = false
    @Published var isPermissionGranted = false
    @Published var errorMessage: String?

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    init() {
        checkPermission()
    }

    func checkPermission() {
        isPermissionGranted = AXIsProcessTrusted()
    }

    func requestPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        AXIsProcessTrustedWithOptions(options as CFDictionary)

        // Polling to check if permission is granted after user action
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if AXIsProcessTrusted() {
                DispatchQueue.main.async {
                    self.isPermissionGranted = true
                }
                timer.invalidate()
            }
        }
    }

    func toggleCleaningMode() {
        errorMessage = nil
        if isCleaningModeEnabled {
            disableCleaningMode()
        } else {
            enableCleaningMode()
        }
    }

    private func enableCleaningMode() {
        guard isPermissionGranted else {
            requestPermission()
            return
        }

        let eventMask = (1 << CGEventType.keyDown.rawValue) |
                        (1 << CGEventType.keyUp.rawValue) |
                        (1 << CGEventType.flagsChanged.rawValue)

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                // Block all keyboard events
                return nil
            },
            userInfo: nil
        ) else {
            print("Failed to create event tap")
            errorMessage = "Failed to engage cleaning mode.\nPlease ensure App Sandbox is DISABLED in Xcode > Signing & Capabilities."
            return
        }

        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)

        isCleaningModeEnabled = true
    }

    private func disableCleaningMode() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
            if let source = runLoopSource {
                CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
            }
            eventTap = nil
            runLoopSource = nil
        }
        isCleaningModeEnabled = false
    }
}
