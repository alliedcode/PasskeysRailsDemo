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
                        defaultAuthClassNameInput()
                        passkeyDomainInput()
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
        TextInput(text: $modelData.apiUrl, label: "API URL", image: "server.rack", placeholder: "https://yourserver.com")
    }
    
    private func defaultAuthClassNameInput() -> some View {
        TextInput(text: $modelData.defaultAuthClassName, label: "Default Auth Class", image: "cube", placeholder: "e.g. User", footnote: "This is optional and can be overridden.")
    }
    
    private func passkeyDomainInput() -> some View {
        TextInput(text: $modelData.passkeyDomain, label: "Passkey Domain", image: "globe.americas")
    }
}

struct SettingsScreen_Previews: PreviewProvider {
    static var previews: some View {
        SettingsScreen()
            .environmentObject(ModelData())
    }
}
