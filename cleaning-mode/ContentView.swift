//
//  ContentView.swift
//  cleaning-mode
//
//  Created by Mulualem Tekle on 26/12/2025.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var keyboardManager: KeyboardManager

    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                // Header / Status
                Text(keyboardManager.isCleaningModeEnabled ? "CLEANING ACTIVE" : "CLEANING INACTIVE")
                    .font(.system(size: 24, weight: .black, design: .monospaced))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 0)
                            .stroke(Color.black, lineWidth: 3)
                    )
                    .background(Color.white)

                // Instructions
                if !keyboardManager.isPermissionGranted {
                    VStack(spacing: 15) {
                        Text("PERMISSION REQUIRED")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(.black)

                        Text("Accessibility permission needed.")
                            .font(.system(size: 14, weight: .regular, design: .monospaced))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)

                        Button(action: {
                            keyboardManager.requestPermission()
                        }) {
                            Text("GRANT")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.black)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 0)
                                        .stroke(Color.black, lineWidth: 3)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(20)
                    .border(Color.black, width: 3)
                } else {
                    // Main Toggle Button
                    Button(action: {
                        keyboardManager.toggleCleaningMode()
                    }) {
                        Text(keyboardManager.isCleaningModeEnabled ? "STOP" : "START")
                            .font(.system(size: 24, weight: .heavy, design: .monospaced))
                            .foregroundColor(keyboardManager.isCleaningModeEnabled ? .white : .black)
                            .frame(width: 200, height: 60)
                            .background(keyboardManager.isCleaningModeEnabled ? Color.black : Color.white)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.black, lineWidth: 4)
                            )
                    }
                    .buttonStyle(NeoButtonStyle())

                    if let errorMessage = keyboardManager.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(10)
                            .background(Color.black)
                            .overlay(
                                Rectangle()
                                    .stroke(Color.red, lineWidth: 2)
                            )
                            .padding(.top, 10)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            keyboardManager.checkPermission()
        }
        .preferredColorScheme(.light)
    }
}

struct NeoButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .offset(x: configuration.isPressed ? 2 : 0, y: configuration.isPressed ? 2 : 0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    ContentView(keyboardManager: KeyboardManager())
}
