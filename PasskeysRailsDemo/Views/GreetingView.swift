//
//  GreetingView.swift
//  PasskeysRailsDemo
//
//  Created by Troy Anderson on 7/31/23.
//

import SwiftUI

struct GreetingView: View {
    var body: some View {
        VStack {
            Image(systemName: "hand.wave")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, there!")
            Text("Welcome to the PasskeysRails Test App")
        }
    }
}

struct GreetingView_Previews: PreviewProvider {
    static var previews: some View {
        GreetingView()
    }
}
