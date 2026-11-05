//
//  cleaning_modeApp.swift
//  cleaning-mode
//
//  Created by Mulualem Tekle on 26/12/2025.
//

import SwiftUI

@main
struct cleaning_modeApp: App {
    @StateObject private var keyboardManager = KeyboardManager()

    var body: some Scene {
        WindowGroup {
            ContentView(keyboardManager: keyboardManager)
                .frame(width: 400, height: 330)
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .commands {
            // Optional: Remove some menu items if needed
        }

        MenuBarExtra {
            Button(action: {
                keyboardManager.toggleCleaningMode()
            }) {
                Text(keyboardManager.isCleaningModeEnabled ? "Stop Cleaning" : "Start Cleaning")
            }

            Divider()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        } label: {
            Image(systemName: keyboardManager.isCleaningModeEnabled ? "keyboard.fill" : "keyboard")
        }
    }
}
