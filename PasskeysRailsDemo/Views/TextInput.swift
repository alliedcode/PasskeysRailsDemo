//
//  TextInput.swift
//  PasskeysRailsDemo
//
//  Created by Troy Anderson on 7/31/23.
//

import SwiftUI

struct TextInput: View {
    let text: Binding<String>
    let label: String
    let image: String
    let placeholder: String?
    let footnote: String?
    
    init(text: Binding<String>, label: String, image: String, placeholder: String? = nil, footnote: String? = nil) {
        self.text = text
        self.label = label
        self.image = image
        self.placeholder = placeholder
        self.footnote = footnote
    }
    
    enum Canned {
        case username
        case classname
    }
    
    init(_ canned: Canned, text: Binding<String>) {
        self.text = text
        
        switch canned {
        case .username:
            self.label = "Username"
            self.image = "person"
            self.placeholder = "Enter username"
            self.footnote = "This must match the regex on the server."

        case .classname:
            self.label = "Optional Class Name"
            self.image = "cube"
            self.placeholder = "e.g. User"
            self.footnote = nil
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Label(label, systemImage: image)
                    .font(.footnote)
                TextField(placeholder ?? "", text: text)
                    .textFieldStyle(.roundedBorder)
            }
            
            if let footnote {
                Text(footnote)
                    .font(.footnote)
                    .italic()
            }
        }
    }
}

struct TextInput_Previews: PreviewProvider {
    static var previews: some View {
        TextInput(text: .constant("bob"), label: "Username", image: "person")
    }
}
