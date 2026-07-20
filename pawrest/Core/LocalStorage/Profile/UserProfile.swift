//
//  UserProfile.swift
//  pawrest
//
//  Created by Moon AYoung on 7/14/26.
//

import Foundation
import SwiftData

@Model
class UserProfile {
    
    @Attribute(.unique)
    var id: UUID
    
    var nickname: String
    var profileImage: Data?
    var createdAt: Date
    
    init(nickname: String, profileImage: Data? = nil, createdAt: Date = Date()) {
        self.id = UUID()
        self.nickname = nickname
        self.profileImage = profileImage
        self.createdAt = createdAt
    }
}
