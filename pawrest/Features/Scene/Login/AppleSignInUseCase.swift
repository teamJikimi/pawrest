//
//  AppleSignInUseCase.swift
//  pawrest
//
//  Created by 예리 on 7/9/26.
//

import Foundation
import FirebaseAuth

public final class AppleSignInUseCase {
    private let signInService: AppleSignInServiceProtocol

    public init(signInService: AppleSignInServiceProtocol) {
        self.signInService = signInService
    }

    public func signIn() async throws -> AppleSignInEntity {
        let entity = try await signInService.signIn()
        
        guard let tokenData = entity.identityToken,
              let idTokenString = String(data: tokenData, encoding: .utf8) else {
            throw AppleSignInServiceError.invalidCredential
        }
        
        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: entity.nonce,
            fullName: entity.fullName
        )
        
        try await Auth.auth().signIn(with: credential)
        
        return entity
    }
}
