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
        HStack {
            Text(label)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .trailing)

            Spacer()

            Text(value == "" ? "<Unset>" : value)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
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
