//
//  AppleSignInUseCase.swift
//  pawrest
//
//  Created by 예리 on 7/9/26.
//

import Foundation

public final class AppleSignInUseCase {
    private let signInService: AppleSignInServiceProtocol

    public init(signInService: AppleSignInServiceProtocol) {
        self.signInService = signInService
    }

    public func signIn() async throws -> AppleSignInEntity {
        try await signInService.signIn()
        // TODO: 추가 로직
    }
}
