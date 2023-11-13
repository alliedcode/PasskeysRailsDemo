//
//  API.swift
//  PasskeysRailsDemo
//
//  Created by Troy Anderson on 7/31/23.
//

import Foundation
import OSLog

enum APIError: LocalizedError {
    case apiError(response: APIErrorResponse, httpResponseCode: Int)
    case invalidURL
    case invalidResponseType
    case invalidData(message: String)
    case baseUrlMissing
    
    public var description: String {
        switch self {
        case .apiError(let response, _):
            return response.message;
        case .invalidURL: return "Invalid URL";
        case .invalidResponseType: return "Invalid response type";
        case .invalidData(let message): return "Invalid data: \(message)";
        case .baseUrlMissing: return "Base URL is missing"
        }
    }
    
    // You need to implement `errorDescription`, not `localizedDescription`.
    public var errorDescription: String? {
        return description
    }
}

struct APIErrorResponse {
    let context: String
    let message: String
    let code: String
}

extension APIErrorResponse: Decodable {
    enum CodingKeys : String, CodingKey {
        case context
        case message
        case code
        case error
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // If it's a proper APIError response, it will have either a .message or an .error key
        message = container.contains(.message) ? try container.decode(String.self, forKey: .message) : try container.decode(String.self, forKey: .error)
        // Optionally, it will have context and code keys
        context = container.contains(.context) ? try container.decode(String.self, forKey: .context) : "API"
        code = container.contains(.code) ? try container.decode(String.self, forKey: .code) : "other"
    }
}

/// Provided by PasskeysRails upon successful registration, authentication, and refresh sequences
struct AuthResponse: Decodable {
    let username: String
    let authToken: String
    
    enum CodingKeys : String, CodingKey {
        case username
        case authToken = "auth_token"
    }
}

protocol APIConfig {
    var apiBase: URL? { get }
}

class API {
    var base: URL?
    
    private static let apikeyHeaderKey = "x-apikey"
    private static let authTokenHeaderKey = "x-auth"

    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()

    enum HTTPMethod {
        case get
        case post(_ body: Encodable? = nil)
        case put(_ body: Encodable? = nil)
        case patch(_ body: Encodable? = nil)
        case delete(_ body: Encodable? = nil)
        
        var stringValue: String {
            switch self {
            case .get: return "GET"
            case .post: return "POST"
            case .put: return "PUT"
            case .patch: return "PATCH"
            case .delete: return "DELETE"
            }
        }
        
        var body: Encodable? {
            switch self {
            case .get: return nil
            case .post(let body): return body
            case .put(let body): return body
            case .patch(let body): return body
            case .delete(let body): return body
            }
        }
        
        func encodedBody(_ encoder: JSONEncoder) throws -> Data? {
            guard let body else { return nil }
            
            return try encoder.encode(body)
        }
    }
    
    init(_ config: APIConfig) {
        base = config.apiBase
    }

    private func url(path: String? = nil, query: [URLQueryItem]? = nil) throws -> URL {
        guard let base else { throw APIError.baseUrlMissing }
        
        var components = URLComponents()
        components.scheme = base.scheme
        components.host = base.host()
        
        if let path {
            components.path = path
        }
        
        components.queryItems = query
        
        guard let url = components.url else { throw APIError.invalidURL }
        
        return url
    }

    private struct APIRequest {
        let api: API
        let log = Logger(subsystem: "API", category: String(UUID().uuidString.suffix(5)))
        let method: HTTPMethod
        let path: String
        let query: [URLQueryItem]?
        let headers: [String:String]
        let logoutOnUnauthorized: Bool
        
        init(api: API, method: HTTPMethod, path: String, query: [URLQueryItem]? = nil, headers: [String : String] = [:], logoutOnUnauthorized: Bool = true) {
            self.api = api
            self.method = method
            self.path = path
            self.query = query
            self.headers = headers
            self.logoutOnUnauthorized = logoutOnUnauthorized
        }
        
        func fetch() async throws -> (Data, HTTPURLResponse) {
            do {
                var request = URLRequest(url: try api.url(path: path, query: query))
                
                request.httpMethod = method.stringValue
                
                log.debug("Sending request: \(method.stringValue, privacy: .public) \(path, privacy: .public)")
                
                if let body = try method.encodedBody(api.jsonEncoder) {
                    request.httpBody = body
                    log.info("Request body: \(String(data: body, encoding: .utf8) ?? "<empty>", privacy: .public)")
                } else {
                    log.info("Request body: <empty>")
                }
                
                // Add content headers
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                
                // Add provided headers
                headers.forEach() { request.setValue($0.value, forHTTPHeaderField: $0.key) }
                
                // Always ignore any cache (we didn't set one up, but just to be safe)
                request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                // URLSession always returns a HTTPURLResponse even though the signatures is URLResponse
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponseType
                }
                
                log.debug("Response status code: \(httpResponse.statusCode, privacy: .public)")
                log.info("Response body: \(String(data: data, encoding: .utf8) ?? "", privacy: .public)")
                
                guard (200...206).contains(httpResponse.statusCode) else {
                    throw buildError(data: data, statusCode: httpResponse.statusCode)
                }
                
                return (data, httpResponse)
            } catch {
                log.error("\(error, privacy: .public)")
                throw error
            }
        }
        
        // Convenience version of fetch() that decodes the response body
        func fetch<Result:Decodable>() async throws -> Result {
            let data: Data
            (data, _) = try await fetch()
            return try api.jsonDecoder.decode(Result.self, from: data)
        }
        
        // Convenience version of fetch() that decodes the response body and also returns the raw response
        func fetch<Result:Decodable>() async throws -> (Result, HTTPURLResponse) {
            let data: Data
            let response: HTTPURLResponse
            (data, response) = try await fetch()
            
            return (try api.jsonDecoder.decode(Result.self, from: data), response)
        }
        
        // Convenience version of fetch() that returns the raw response
        func fetch() async throws -> HTTPURLResponse {
            let response: HTTPURLResponse
            (_, response) = try await fetch()
            
            return response
        }
        
        // Convenience version of fetch() that ignores the response body
        func fetch() async throws {
            (_, _) = try await fetch()
        }

        struct APIErrorResponseWrapper: Decodable {
            let error: APIErrorResponse
        }
        
        private func buildError(data: Data, statusCode: Int) -> APIError {
            let errorResponse: APIErrorResponse
            
            if let r = try? api.jsonDecoder.decode(APIErrorResponseWrapper.self, from: data) {
                errorResponse = r.error
            } else if let responseString = String(data: data, encoding: .utf8), !responseString.isEmpty {
                errorResponse = APIErrorResponse(context: "API", message: responseString, code: "other")
            } else {
                errorResponse = APIErrorResponse(context: "API", message: "Unknown server error", code: "other")
            }
            
            return APIError.apiError(response: errorResponse, httpResponseCode: statusCode)
        }
    }
}

// MARK: - API Methods -
extension API {
    static let passkeyChallengePath = "/passkeys/challenge"
    static let passkeyFinalizeRegistrationPath = "/passkeys/register"
    static let passkeyFinalizeAuthenticationPath = "/passkeys/authenticate"
    static let passkeyRefreshPath = "/passkeys/refresh"
    static let passkeyDebugRegisterPath = "/passkeys/debug_register"
    static let passkeyDebugLoginPath = "/passkeys/debug_login"
}

extension API {
    func passkeyRegistrationChallenge(username: String) async throws -> CredentialCreationOptions {
        let request = APIRequest(api: self, method: .post(["username": username]), path: API.passkeyChallengePath)
        
        return try await request.fetch()
    }
    
    func passkeyAuthenticationChallenge() async throws -> CredentialAssertionOptions {
        let request = APIRequest(api: self, method: .post(), path: API.passkeyChallengePath)
        
        return try await request.fetch()
    }
    
    struct Authenticatable<P:Encodable>: Encodable {
        let `class`: String
        let params: P?
    }

    private struct RegisterParams<P:Encodable>: Encodable {
        let credential: RegistrationCredential
        let authenticatable: Authenticatable<P>?
    }

    func passkeyRegister<P:Encodable>(credential: RegistrationCredential, authenticatable: Authenticatable<P>?) async throws -> AuthResponse {
        let params = RegisterParams(credential: credential, authenticatable: authenticatable)
        let request = APIRequest(api: self, method: .post(params), path: API.passkeyFinalizeRegistrationPath)
        
        return try await request.fetch()
    }

    func passkeyRegister(credential: RegistrationCredential, className: String? = nil) async throws -> AuthResponse {
        struct Empty: Encodable {}
        let authenticatable = className.map { Authenticatable<Empty>(class: $0, params: nil) }
        return try await passkeyRegister(credential: credential, authenticatable: authenticatable)
    }
    
    func passkeyAuthenticate(credential: AssertionCredential) async throws -> AuthResponse {
        let request = APIRequest(api: self, method: .post(credential), path: API.passkeyFinalizeAuthenticationPath)
        
        return try await request.fetch()
    }
    
    func passkeyRefresh(authToken: String) async throws -> AuthResponse {
        let request = APIRequest(api: self, method: .post(["auth_token": authToken]), path: API.passkeyRefreshPath)
        return try await request.fetch()
    }
    
#if targetEnvironment(simulator)
    private struct DebugRegisterParams<P:Encodable>: Encodable {
        let username: String
        let authenticatable: Authenticatable<P>?
    }
    
    func passkeyDebugRegister<P:Encodable>(username: String, authenticatable: Authenticatable<P>? = nil) async throws -> AuthResponse {
        let params = DebugRegisterParams(username: username, authenticatable: authenticatable)
        let request = APIRequest(api: self, method: .post(params), path: API.passkeyDebugRegisterPath)
        
        return try await request.fetch()
    }
    
    func passkeyDebugRegister(username: String, className: String? = nil) async throws -> AuthResponse {
        struct Empty: Encodable {}
        let authenticatable = className.map { Authenticatable<Empty>(class: $0, params: nil) }
        return try await passkeyDebugRegister(username: username, authenticatable: authenticatable)
    }

    func passkeyDebugLogin(username: String) async throws -> AuthResponse {
        let request = APIRequest(api: self, method: .post(["username": username]), path: API.passkeyDebugLoginPath)
        
        return try await request.fetch()
    }
#endif
}
