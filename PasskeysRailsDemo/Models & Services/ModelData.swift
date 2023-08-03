//
//  ModelData.swift
//  PasskeysRailsDemo
//
//  Created by Troy Anderson on 7/31/23.
//

import Foundation
import SwiftUI
import AuthenticationServices

@MainActor
class ModelData: ObservableObject {
    struct Config: PasskeyManagerConfig, APIConfig {
        var domain: String
        var apiBase: URL?
    }
    
    @AppStorage("apiUrl") var apiUrl: String = "localhost:3000" {
        didSet {
            config.apiBase = URL(string: apiUrl)
            api = API(config)
        }
    }
    
    @AppStorage("passkeyDomain") var passkeyDomain: String = "localhost" {
        didSet {
            // Rebuild the PasskeyManager if the domain changes (not really a production use case)
            config.domain = passkeyDomain
            passkeyManager = PasskeyManager(config)
        }
    }
    
    @AppStorage("defaultAuthClassName") var defaultAuthClassName: String = ""
    
    @Published var loggedIn = false
    @Published var username: String?
    
    private(set) var api: API
    private(set) var config: Config
    private(set) var passkeyManager: PasskeyManager
    
    private var auth: AuthResponse? {
        didSet {
            loggedIn = auth != nil
            username = auth?.username
        }
    }
    
    init() {
        config = Config(domain: "localhost")
        passkeyManager = PasskeyManager(config)
        api = API(config)
    }
    
    func loginWith(_ authResponse: AuthResponse) {
        auth = authResponse
    }
    
    func logout() {
        auth = nil
    }
}
