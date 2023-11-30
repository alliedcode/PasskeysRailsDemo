//
//  SettingsScreen.swift
//  PasskeysRailsDemo
//
//  Created by Troy Anderson on 7/31/23.
//

import SwiftUI

struct SettingsScreen: View {
    @EnvironmentObject var modelData: ModelData
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack(spacing: 20) {
                        Divider()
                        
                        apiUrlInput()
                        passkeyDomainInput()
                        defaultAuthClassNameInput()
                    }
                }
                
                Spacer()
                Divider()
                StatusView()
                Divider()
            }
            .padding()
            .navigationTitle("Settings")
        }
    }
    
    private func apiUrlInput() -> some View {
        TextInput(text: $modelData.apiUrl, label: "API URL", image: "server.rack", placeholder: "https://yourserver.com", footnote: "Something like https://app.yourdomain.com")
            .keyboardType(.URL)
            .autocapitalization(.none)
    }
    
    private func defaultAuthClassNameInput() -> some View {
        TextInput(text: $modelData.defaultAuthClassName, label: "Default Auth Class", image: "cube", placeholder: "e.g. User", footnote: "This is optional and can be overridden.")
            .autocorrectionDisabled()
            .autocapitalization(.none)
    }
    
    private func passkeyDomainInput() -> some View {
        TextInput(text: $modelData.passkeyDomain, label: "Passkey Domain", image: "globe.americas", footnote: "Probably the same as your API URL, but without the protocol - something like app.yourdomain.com")
            .keyboardType(.URL)
            .autocorrectionDisabled()
            .autocapitalization(.none)
    }
}

struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreen()
            .environmentObject(ModelData())
    }
}
