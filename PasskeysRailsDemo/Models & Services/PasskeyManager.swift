//
//  PasskeyManager.swift
//  PasskeysRailsDemo
//
//  Created by Troy Anderson on 7/31/23.
//


import AuthenticationServices
import SwiftUI

public enum AuthorizationHandlingError: Error {
    case userCancelled
    case unexpectedAuthorizationResult(ASAuthorizationResult)
    case otherError(String)
}

extension AuthorizationHandlingError: LocalizedError {
    public var errorDescription: String? {
            switch self {
            case .userCancelled:
                return NSLocalizedString("User cancelled", comment: "Human readable description of the user cancelled result.")
            case .unexpectedAuthorizationResult:
                return NSLocalizedString("Received an unexpected authorization result.",
                                         comment: "Human readable description of receiving an unexpected authorization result.")
            case .otherError(let description):
                return description
            }
        }
}

/// Provided by PasskeysRails to  be provided to the platform when creating a new passkey
public struct CredentialCreationOptions : Decodable {
    let challenge: String
    let user: User

    struct User : Decodable {
        let id: String
        let name: String
        let displayName: String
    }
}

/// Provided by PasskeysRails to  be provided to the platform when verifying an existing passkey
public struct CredentialAssertionOptions : Decodable {
    let challenge: String
}

/// Sent to PasskeysRails so it can validate the registration (public key)
struct RegistrationCredential: Encodable {
    var type: String { "public-key" }
    let id: String
    var rawId: String { id }
    let response: Response
    
    init(registration: ASAuthorizationPlatformPublicKeyCredentialRegistration) {
        id = registration.credentialID.base64EncodedString()
        response = Response(registration: registration)
    }
    
    struct Response: Encodable {
        let attestationObject: String
        let clientDataJSON: String
        
        init(registration: ASAuthorizationPlatformPublicKeyCredentialRegistration) {
            attestationObject = registration.rawAttestationObject!.base64EncodedString()
            clientDataJSON = registration.rawClientDataJSON.base64EncodedString()
        }
    }
}

/// Sent to PasskeysRails so it can validate the assertion (signature)
struct AssertionCredential: Encodable {
    var type: String { "public-key" }
    let id: String
    var rawId: String { id }
    let response: Response
    
    init(assertion: ASAuthorizationPlatformPublicKeyCredentialAssertion) {
        id = assertion.credentialID.base64EncodedString()
        response = Response(assertion: assertion)
    }
    
    struct Response: Encodable {
        let authenticatorData: String
        let clientDataJSON: String
        let signature: String
        let userHandle: String
        
        // Build a credential from the assertion
        init(assertion: ASAuthorizationPlatformPublicKeyCredentialAssertion) {
            authenticatorData = assertion.rawAuthenticatorData.base64EncodedString()
            clientDataJSON = assertion.rawClientDataJSON.base64EncodedString()
            signature = assertion.signature.base64EncodedString()
            userHandle = assertion.userID.base64EncodedString()
        }
    }
}

public protocol PasskeyManagerConfig {
    var domain: String { get }
}

@MainActor
final class PasskeyManager {
    private let domain: String

    public init(_ config: PasskeyManagerConfig) {
        self.domain = config.domain
    }

    public func createPasskeyAccount(
        authorizationController: AuthorizationController,
        creationOptions: CredentialCreationOptions,
        requestOptions: ASAuthorizationController.RequestOptions = [])
    async throws -> RegistrationCredential {
        let requests = try passkeyRegistrationRequests(challenge: creationOptions.challenge, username: creationOptions.user.name, userId: creationOptions.user.id)
        
        let result = try await performAuthRequests(
            authorizationController: authorizationController,
            requests: requests,
            options: requestOptions)

        // Be sure it's the correct response type and extract the registration
        guard case .passkeyRegistration(let passkeyRegistration) = result else {
            throw AuthorizationHandlingError.unexpectedAuthorizationResult(result)
        }

        return RegistrationCredential(registration: passkeyRegistration)
    }
    
    public func signIntoPasskeyAccount(
        authorizationController: AuthorizationController,
        assertionOptions: CredentialAssertionOptions,
        requestOptions: ASAuthorizationController.RequestOptions = [])
    async throws -> AssertionCredential {
        let requests = try signInRequests(challenge: assertionOptions.challenge)
        
        let result = try await performAuthRequests(
            authorizationController: authorizationController,
            requests: requests,
            options: requestOptions)
        
        // Be sure it's the correct response type and extract the assertion
        guard case .passkeyAssertion(let passkeyAssertion) = result else {
            throw AuthorizationHandlingError.unexpectedAuthorizationResult(result)
        }
        
        return AssertionCredential(assertion: passkeyAssertion)
    }
    
    func performAuthRequests(
        authorizationController: AuthorizationController,
        requests: [ASAuthorizationRequest],
        options: ASAuthorizationController.RequestOptions = [])
    async throws -> ASAuthorizationResult {
        do {
            return try await authorizationController.performRequests(requests, options: options)
        } catch let authorizationError as ASAuthorizationError where authorizationError.code == .canceled {
            // The user cancelled the requests.
            throw AuthorizationHandlingError.userCancelled
        } catch let authorizationError as ASAuthorizationError {
            // Some other error occurred.
            throw AuthorizationHandlingError.otherError("Passkey requests failed. Error: \(authorizationError.localizedDescription)")
        } catch {
            // Some other error occurred while handling the requests.
            throw AuthorizationHandlingError.otherError("""
            Passkey requests handling failed. \
            Caught an unknown error during passkey requests or handling: \(error.localizedDescription)
            """)
        }
    }

    // MARK: - Private

    private func passkeyRegistrationRequests(challenge: String, username: String, userId: String) throws -> [ASAuthorizationRequest] {
        let registrationRequest = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: domain)
           .createCredentialRegistrationRequest(challenge: Data(challenge.utf8), name: username, userID: Data(userId.utf8))
        
        return [registrationRequest]
    }

    private func signInRequests(challenge: String) throws -> [ASAuthorizationRequest] {
        let assertionRequest = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: domain)
            .createCredentialAssertionRequest(challenge: Data(challenge.utf8))

        return [assertionRequest, ASAuthorizationPasswordProvider().createRequest()]
    }
}
