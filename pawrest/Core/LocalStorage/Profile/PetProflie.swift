//
//  PetProflie.swift
//  pawrest
//
//  Created by Moon AYoung on 7/14/26.
//

import Foundation
import SwiftData

@Model
class PetProfile {
    @Attribute(.unique)
    var id: UUID
    
    var name: String
    var profileImage: Data?
    var birthday: Date?
    var deathDay: Date?
    var createdAt: Date
    
    init(name: String, profileImage: Data? = nil, birthday: Date? = nil, deathDay: Date? = nil, createdAt: Date = Date()) {
        self.id = UUID()
        self.name = name
        self.profileImage = profileImage
        self.birthday = birthday
        self.deathDay = deathDay
        self.createdAt = createdAt
    }
}
