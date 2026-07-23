//
//  LetterModel.swift
//  pawrest
//
//  Created by 소은 on 7/23/26.
//

import Foundation
import SwiftData

@Model
final class LetterModel {
    var id: UUID
    var petName: String
    var content: String
    var sentAt: Date

    init(petName: String, content: String, sentAt: Date = Date()) {
        self.id = UUID()
        self.petName = petName
        self.content = content
        self.sentAt = sentAt
    }
}
