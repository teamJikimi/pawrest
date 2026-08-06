//
//  AuthSessionClient.swift
//  pawrest
//
//  Created by Moon AYoung on 8/6/26.
//

import ComposableArchitecture
import FirebaseAuth

struct AuthSessionClient {
    var currentUserID: @Sendable () -> String?
}

extension AuthSessionClient: DependencyKey {
    static let liveValue = Self(
        currentUserID: {
            Auth.auth().currentUser?.uid
        }
    )
}

extension DependencyValues {
    var authSessionClient: AuthSessionClient {
        get { self[AuthSessionClient.self] }
        set { self[AuthSessionClient.self] = newValue }
    }
}
