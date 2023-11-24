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
        }
    }
    
    @AppStorage("passkeyDomain") var passkeyDomain: String = "localhost" {
        didSet {
            // Rebuild the PasskeyManager if the domain changes (not really a production use case)
            config.domain = passkeyDomain
        }
    }
    
    @AppStorage("defaultAuthClassName") var defaultAuthClassName: String = ""
    
    @Published var loggedIn = false
    @Published var username: String?

    var passkeyManager: PasskeyManager {
        let passkeyManager = _passkeyManager ?? PasskeyManager(config)
        _passkeyManager = passkeyManager
        
        return passkeyManager
    }
    
    var api: API {
        let api = _api ?? API(config)
        _api = api
        
        return api
    }

    private(set) var config = Config(domain: "localhost") {
        didSet {
            _passkeyManager = nil
            _api = nil
        }
    }
    private var _passkeyManager: PasskeyManager?
    private var _api: API?
    private var auth: AuthResponse? {
        didSet {
            loggedIn = auth != nil
            username = auth?.username
        }
    }
    
    init() {
        config = Config(domain: passkeyDomain, apiBase: URL(string: apiUrl))
    }
    
    func loginWith(_ authResponse: AuthResponse) {
        auth = authResponse
    }
    
    func logout() {
        auth = nil
    }
}
