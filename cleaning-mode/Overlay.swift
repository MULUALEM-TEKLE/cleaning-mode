import SwiftUI

/// A dark cover on every display while the keyboard is locked.
final class Overlay {
    private var windows: [NSWindow] = []

    func show(_ lock: KeyboardLock) {
        NSApp.activate(ignoringOtherApps: true)
        windows = NSScreen.screens.map { screen in
            let window = KeyWindow(contentRect: screen.frame, styleMask: .borderless, backing: .buffered, defer: false)
            window.setFrame(screen.frame, display: false)
            window.level = .screenSaver
            window.isOpaque = false
            window.backgroundColor = .clear
            window.isReleasedWhenClosed = false
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
            window.contentView = NSHostingView(rootView: OverlayView(lock: lock))
            window.alphaValue = 0
            window.orderFrontRegardless()
            return window
        }
        windows.first?.makeKey()  // key window: the Done button draws active and takes the first click
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            windows.forEach { $0.animator().alphaValue = 1 }
        }
    }

    func hide() {
        let closing = windows
        windows = []
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            closing.forEach { $0.animator().alphaValue = 0 }
        } completionHandler: {
            MainActor.assumeIsolated { closing.forEach { $0.orderOut(nil) } }
        }
    }
}

/// Borderless windows refuse key status by default.
private final class KeyWindow: NSWindow {
    override var canBecomeKey: Bool { true }
}

struct OverlayView: View {
    @ObservedObject var lock: KeyboardLock

    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()
            VStack(spacing: 24) {
                Image(systemName: "bubbles.and.sparkles.fill")
                    .font(.system(size: 80))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.cyan, Color("AccentColor"))
                    .symbolEffect(.bounce, value: lock.blockedPresses)
                Text("Keyboard locked")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                Text("Wipe away. Nothing you press goes through.")
                    .font(.system(size: 22))
                    .foregroundStyle(.white.opacity(0.7))
                // min(): the view redraws once more after the timer ends, while it fades out.
                Text(timerInterval: min(.now, lock.endDate)...lock.endDate, countsDown: true)
                    .font(.system(size: 104, weight: .semibold, design: .rounded).monospacedDigit())
                    .padding(.top, 8)
                Text("^[\(lock.blockedPresses) press](inflect: true) blocked")
                    .font(.system(size: 20).monospacedDigit())
                    .foregroundStyle(.white.opacity(0.7))
                    .contentTransition(.numericText(value: Double(lock.blockedPresses)))
                    .animation(.snappy, value: lock.blockedPresses)
                Button { lock.unlock() } label: {
                    Text("Done").frame(width: 160)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.extraLarge)
                .padding(.top, 8)
                Text("Avoid the power or Touch ID key. It locks your Mac.")
                    .font(.system(size: 15))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .foregroundStyle(.white)
        }
        .environment(\.colorScheme, .dark)
    }
}
