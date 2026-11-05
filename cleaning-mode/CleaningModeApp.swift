import ServiceManagement
import SwiftUI

@main
struct CleaningModeApp: App {
    @StateObject private var lock = KeyboardLock()

    var body: some Scene {
        MenuBarExtra {
            MenuView(lock: lock)
        } label: {
            Image(systemName: lock.isLocked ? "bubbles.and.sparkles.fill" : "keyboard")
        }
        .menuBarExtraStyle(.window)
    }
}

struct MenuView: View {
    @ObservedObject var lock: KeyboardLock
    @AppStorage("seconds") private var seconds = 60
    @State private var openAtLogin = SMAppService.mainApp.status == .enabled

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 36, height: 36)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Cleaning Mode").font(.headline)
                    Text("Lock the keyboard. Wipe it clean.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if lock.isTrusted {
                Picker("Lock for", selection: $seconds) {
                    Text("30 s").tag(30)
                    Text("1 min").tag(60)
                    Text("2 min").tag(120)
                    Text("5 min").tag(300)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                Button { lock.lock(for: TimeInterval(seconds)) } label: {
                    Label("Start Cleaning", systemImage: "bubbles.and.sparkles")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .keyboardShortcut(.defaultAction)
                .disabled(lock.isLocked)
            } else {
                Text("Cleaning Mode needs Accessibility access to block key presses. It does not read or store what you type.")
                    .font(.callout)
                    .fixedSize(horizontal: false, vertical: true)
                Button { lock.requestAccess() } label: {
                    Text("Allow Access…").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }

            if let error = lock.error {
                Text(error)
                    .font(.callout)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Divider()
            Toggle("Open at Login", isOn: $openAtLogin)
                .toggleStyle(.switch)
                .controlSize(.small)
                .onChange(of: openAtLogin) { _, on in
                    try? on ? SMAppService.mainApp.register() : SMAppService.mainApp.unregister()
                    openAtLogin = SMAppService.mainApp.status == .enabled
                }
            HStack {
                Link("Source on GitHub", destination: URL(string: "https://github.com/MULUALEM-TEKLE/cleaning-mode")!)
                Spacer()
                Button("Quit") { NSApp.terminate(nil) }
                    .keyboardShortcut("q")
            }
            .font(.callout)
        }
        .padding(16)
        .frame(width: 300)
        .onAppear { lock.refreshTrust() }
    }
}
