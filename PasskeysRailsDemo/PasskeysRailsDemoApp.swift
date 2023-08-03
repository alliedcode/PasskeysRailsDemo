//
//  PasskeysRailsDemoApp.swift
//  PasskeysRailsDemo
//
//  Created by Troy Anderson on 7/31/23.
//

import SwiftUI

@main
struct PasskeysRailsDemoApp: App {
    @StateObject private var modelData = ModelData()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(modelData)
        }
    }
}
