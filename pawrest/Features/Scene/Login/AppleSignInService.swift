//
//  AppleSignInService.swift
//  pawrest
//
//  Created by 예리 on 7/9/26.
//

import AuthenticationServices
import UIKit

public final class AppleSignInService: NSObject, AppleSignInServiceProtocol {
    private var continuation: CheckedContinuation<AppleSignInEntity, Error>?

    public override init() {
        super.init()
    }

    public func signIn() async throws -> AppleSignInEntity {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleSignInService: ASAuthorizationControllerDelegate {
    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            continuation?.resume(throwing: AppleSignInServiceError.invalidCredential)
            continuation = nil
            return
        }

        let entity = AppleSignInEntity(
            userIdentifier: credential.user,
            email: credential.email,
            fullName: credential.fullName,
            identityToken: credential.identityToken
        )
        continuation?.resume(returning: entity)
        continuation = nil
    }

    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}

extension AppleSignInService: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        let windowScene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive })
            ?? UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first!

        if let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
            return keyWindow
        }

        return UIWindow(windowScene: windowScene)
    }
}

public enum AppleSignInServiceError: Error, Equatable {
    case invalidCredential
}
