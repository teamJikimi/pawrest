//
//  AppleSignInEntity.swift
//  pawrest
//
//  Created by 예리 on 7/9/26.
//

import Foundation

public struct AppleSignInEntity: Equatable {
    public let userIdentifier: String
    public let email: String?
    public let fullName: PersonNameComponents?
    public let identityToken: Data?
}
