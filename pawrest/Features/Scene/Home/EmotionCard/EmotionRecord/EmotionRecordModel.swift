//
//  EmotionRecordModel.swift
//  pawrest
//
//  Created by 소은 on 6/12/26.
//

import SwiftData
import Foundation

@Model
final class EmotionRecordModel {
    var id: UUID
    var emotionType: String
    var memo: String
    var recordedAt: Date

    init(
        id: UUID = UUID(),
        emotionType: String,
        memo: String,
        recordedAt: Date = Date()
    ) {
        self.id = id
        self.emotionType = emotionType
        self.memo = memo
        self.recordedAt = recordedAt
    }
}

// MARK: - Helper

extension EmotionRecordModel {
    var emotionTypeEnum: EmotionType? {
        switch emotionType {
        case "comfortable": return .comfortable
        case "stable":      return .stable
        case "normal":      return .normal
        case "frustrated":  return .frustrated
        case "depressed":   return .depressed
        default:            return nil
        }
    }
}
