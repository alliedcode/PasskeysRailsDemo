//
//  ContentView.swift
//  PasskeysRailsDemo
//
//  Created by Troy Anderson on 7/31/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var modelData: ModelData
    
    var body: some View {
        TabView() {
            AboutScreen()
                .tabItem{ Label("About", systemImage: "face.smiling") }
#if targetEnvironment(simulator)
            DebugAuthScreen()
                .tabItem{ Label("Testing", systemImage: "testtube.2") }
#endif
            PasskeyAuthScreen()
                .tabItem{ Label("Passkeys", systemImage: "person.badge.key") }
            SettingsScreen()
                .tabItem{ Label("Settings", systemImage: "gear") }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ModelData())
    }
}
