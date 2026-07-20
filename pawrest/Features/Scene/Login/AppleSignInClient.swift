//
//  AppleSignInClient.swift
//  pawrest
//
//  Created by 곽예리 on 7/9/26.
//

import ComposableArchitecture

struct AppleSignInClient {
    var signIn: () async throws -> AppleSignInEntity
}

extension AppleSignInClient: DependencyKey {
    static let liveValue: AppleSignInClient = {
        let useCase = AppleSignInUseCase(signInService: AppleSignInService())
        return AppleSignInClient(
            signIn: { try await useCase.signIn() }
        )
    }()
}

extension DependencyValues {
    var appleSignInClient: AppleSignInClient {
        get { self[AppleSignInClient.self] }
        set { self[AppleSignInClient.self] = newValue }
    }
}
