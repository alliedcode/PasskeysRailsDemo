//
//  DebugAuthScreen.swift
//  PasskeysRailsDemo
//
//  Created by Troy Anderson on 7/31/23.
//

import SwiftUI

struct DebugAuthScreen: View {
    @EnvironmentObject var modelData: ModelData
    @State var registerUsername = ""
    @State var authUsername = ""
    @State var className = ""
    @State var registerLog: [String] = []
    @State var authLog: [String] = []

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack(spacing: 20) {
                        Divider()
                        
                        VStack {
                            Text("Registration")
                                .font(.headline)
                            TextInput(.username, text: $registerUsername)
                            TextInput(.classname, text: $className)
                            debugRegisterButton()
                            debugRegisterFooter()
                                .font(.subheadline)
                            LogView(entries: $registerLog)
                                .animation(.default, value: registerLog)
                        }
                        
                        Divider()
                        
                        VStack {
                            Text("Authentication")
                                .font(.headline)
                            TextInput(.username, text: $authUsername)
                            debugAuthenticateButton()
                            debugAuthenticateFooter()
                                .font(.subheadline)
                            LogView(entries: $authLog)
                                .animation(.default, value: authLog)
                        }
                        
                    }
                }
                
                Spacer()
                Divider()
                StatusView()
                Divider()
            }
            .padding(.horizontal)
            .buttonStyle(.borderedProminent)
            .navigationTitle("Test Passkeys")
        }
        .task {
            if className == "" {
                className = modelData.defaultAuthClassName
            }
        }
    }
    
    private func debugRegisterButton() -> some View {
        Button {
            debugRegister(username: registerUsername, className: className)
        } label: {
            Text("Test Register")
                .frame(minWidth: 200)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func debugAuthenticateButton() -> some View {
        Button {
            debugAuthenticate(username: authUsername)
        } label: {
            Text("Test Authenticate")
                .frame(minWidth: 200)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func debugRegisterFooter() -> some View {
        VStack(spacing: 6) {
            Text("POST /passkeys/debug_register")
        }
        .frame(maxWidth: .infinity)
    }
    
    private func debugAuthenticateFooter() -> some View {
        VStack(spacing: 6) {
            Text("POST /passkeys/debug_login")
        }
        .frame(maxWidth: .infinity)
    }
    
    private func debugRegister(username: String, className: String) {
        Task {
            do {
                let result = try await modelData.api.passkeyDebugRegister(username: registerUsername, className: className == "" ? nil : className)
                registerLog.append(result.authToken)
            } catch {
                registerLog.append(error.localizedDescription)
            }
        }
    }

    private func debugAuthenticate(username: String) {
        Task {
            do {
                let result = try await modelData.api.passkeyDebugLogin(username: authUsername)
                authLog.append(result.authToken)
            } catch {
                authLog.append(error.localizedDescription)
            }
        }
    }

}

struct DebugAuthScreen_Previews: PreviewProvider {
    static var previews: some View {
        DebugAuthScreen()
            .environmentObject(ModelData())
    }
}
