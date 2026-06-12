//
//  EmotionCheckInModel.swift
//  pawrest
//
//  Created by 소은 on 6/12/26.
//

import Foundation

// MARK: - Model

enum EmotionType: String, CaseIterable {
    case comfortable
    case stable
    case normal
    case frustrated
    case depressed

    var label: String {
        switch self {
        case .comfortable: return "편안"
        case .stable:      return "안정"
        case .normal:      return "보통"
        case .frustrated:  return "답답"
        case .depressed:   return "우울"
        }
    }

    var imageName: String {
        switch self {
        case .comfortable: return "image_comfortable"
        case .stable:      return "image_stability"
        case .normal:      return "image_normal"
        case .frustrated:  return "image_frustrated"
        case .depressed:   return "image_melancholy"
        }
    }
}

// MARK: - Mock

extension EmotionCheckInFeature.State {
    static let mock = EmotionCheckInFeature.State(
        selectedEmotion: .comfortable,
        memoText: "",
        dateText: "06월 12일 (목) 02:36"
    )
}
