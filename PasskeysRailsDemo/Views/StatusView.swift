//
//  StatusView.swift
//  PasskeysRailsDemo
//
//  Created by Troy Anderson on 7/31/23.
//

import SwiftUI

struct StatusView: View {
    @EnvironmentObject var modelData: ModelData
    
    var body: some View {
        VStack {
            Text("Status")
                .font(.headline)
            
            if modelData.loggedIn {
                Text("You are logged in.")
                KeyValueRow(label: "Username", value: modelData.username ?? "")
                    .padding(.bottom)
            } else {
                Text("You are not logged in.")
                    .font(.footnote)
                    .padding(.bottom)
            }

            KeyValueRow(label: "API URL", value: modelData.apiUrl)
                .padding(.bottom)
            
            KeyValueRow(label: "Default Auth Class", value: modelData.defaultAuthClassName)
                .padding(.bottom)
        }
        .frame(maxWidth: .infinity)
        .foregroundColor(.secondary)
    }
}

struct StatusView_Previews: PreviewProvider {
    static var previews: some View {
        StatusView()
            .environmentObject(ModelData())
    }
}
