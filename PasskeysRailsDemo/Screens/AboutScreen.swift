//
//  AboutScreen.swift
//  PasskeysRailsDemo
//
//  Created by Troy Anderson on 7/31/23.
//

import SwiftUI

struct AboutScreen: View {
    var body: some View {
        VStack {
            GreetingView()
            
            List {
                Label("Set up your rails back end using the passkeys-rails gem", systemImage: "1.circle")
                Label("Set the API URL in this app's Settings tab", systemImage: "2.circle")
                Label("Test using the Testing tab in the simulator", systemImage: "3.circle")
                Label("Test using the Passkeys tab on a real device", systemImage: "4.circle")
            }
        }
    }
}

struct AboutScreen_Previews: PreviewProvider {
    static var previews: some View {
        AboutScreen()
            .environmentObject(ModelData())
    }
}
