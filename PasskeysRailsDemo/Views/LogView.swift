//
//  LogView.swift
//  PasskeysRailsDemo
//
//  Created by Troy Anderson on 8/1/23.
//

import SwiftUI

struct LogView: View {
    var entries: Binding<[String]>
    
    var body: some View {
        Group {
            if entries.wrappedValue.isEmpty {
                EmptyView()
            } else {
                VStack {
                    Button("Clear Log") {
                        withAnimation {
                            entries.wrappedValue = []
                        }
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.accentColor)
                    .font(.body)
                    
                    VStack {
                        ForEach(entries.wrappedValue, id: \.self) { log in
                            Text(log)
                                .font(.footnote)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(8)
                    .background(Color.black)
                    .foregroundColor(.green)
                    
                }
            }
        }
    }
}

struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        LogView(entries: .constant(["123", "546"]))
    }
}
