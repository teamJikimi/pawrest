//
//  AppleSignInServiceProtocol.swift
//  pawrest
//
//  Created by 곽예리 on 7/9/26.
//

import Foundation

public protocol AppleSignInServiceProtocol {
    func signIn() async throws -> AppleSignInEntity
}
