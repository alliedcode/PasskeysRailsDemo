//
//  KeyValueRow.swift
//  PasskeysRailsDemo
//
//  Created by Troy Anderson on 7/31/23.
//

import SwiftUI

struct KeyValueRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack {
            Text(label)
                .font(.headline)
        
            Text(value == "" ? "<Unset>" : value)
                .font(.footnote)
        }
    }
}

struct KeyValueRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            KeyValueRow(label: "Label", value: "Value")
            KeyValueRow(label: "Label", value: "")
        }
    }
}
