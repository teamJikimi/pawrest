//
//  SelfAssessmentResultFeature.swift
//  pawrest
//
//  Created by 소은 on 6/14/26.
//

import SwiftUI
import ComposableArchitecture

// MARK: - Assessment Type

enum AssessmentType: Equatable {
    case pbq
    case cesD
    case pds

    var source: String {
        switch self {
        case .pbq:  return "Hunt & Padilla (2006)"
        case .cesD: return "Radloff (1977)"
        case .pds:  return "Foa et al. (1997)"
        }
    }
    
    var title: String {
        switch self {
        case .pbq:  return "PBQ 펫로스 심리 척도"
        case .cesD: return "CES-D 우울감 척도"
        case .pds:  return "PDS 외상 스트레스 척도"
        }
    }

    var maxScore: Int {
        switch self {
        case .pbq:  return 60
        case .cesD: return 60
        case .pds:  return 60
        }
    }

    var interpretationRows: [AssessmentInterpretationRow] {
        switch self {
        case .pbq:
            return [
                .init(level: .pbqLow),
                .init(level: .pbqAverage),
                .init(level: .pbqHigh)
            ]
        case .cesD:
            return [
                .init(level: .cesDNormal),
                .init(level: .cesDHighRisk),
                .init(level: .cesDDepression)
            ]
        case .pds:
            return [
                .init(level: .pdsMild),
                .init(level: .pdsModerate),
                .init(level: .pdsModerateToSevere),
                .init(level: .pdsSevere)
            ]
        }
    }

    func scoreLevel(for score: Int) -> AssessmentScoreLevel {
        switch self {
        case .pbq:
            if score < 28 { return .pbqLow }
            if score < 37 { return .pbqAverage }
            return .pbqHigh

        case .cesD:
            if score <= 20 { return .cesDNormal }
            if score <= 40 { return .cesDHighRisk }
            return .cesDDepression

        case .pds:
            if score <= 20 { return .pdsMild }
            if score <= 40 { return .pdsModerate }
            if score <= 60 { return .pdsModerateToSevere }
            return .pdsSevere
        }
    }
}

// MARK: - Score Level

enum AssessmentScoreLevel: Equatable {
    // PBQ
    case pbqLow
    case pbqAverage
    case pbqHigh

    // CES-D
    case cesDNormal
    case cesDHighRisk
    case cesDDepression

    // PDS
    case pdsMild
    case pdsModerate
    case pdsModerateToSevere
    case pdsSevere

    var label: String {
        switch self {
        case .pbqLow:               return "평균 미만"
        case .pbqAverage:           return "평균 이상"
        case .pbqHigh:              return "상위 30% 펫로스 증후군"
        case .cesDNormal:           return "정상"
        case .cesDHighRisk:         return "우울 고위험군"
        case .cesDDepression:       return "우울증 고위험군"
        case .pdsMild:              return "경도 수준"
        case .pdsModerate:          return "중등도 수준"
        case .pdsModerateToSevere:  return "중등도-중증 수준"
        case .pdsSevere:            return "중증 수준"
        }
    }

    var rangeText: String {
        switch self {
        case .pbqLow:               return "28점 미만"
        case .pbqAverage:           return "28점 이상"
        case .pbqHigh:              return "37점 이상"
        case .cesDNormal:           return "0~20점"
        case .cesDHighRisk:         return "21~40점"
        case .cesDDepression:       return "41~60점"
        case .pdsMild:              return "0~20점"
        case .pdsModerate:          return "21~40점"
        case .pdsModerateToSevere:  return "41~60점"
        case .pdsSevere:            return "41~60점"
        }
    }

    var icon: ImageResource {
        switch self {
        case .pbqLow, .cesDNormal, .pdsMild:
            return .iconLevelLow
        case .pbqAverage, .pdsModerate:
            return .iconLevelModerate
        case .cesDHighRisk, .pdsModerateToSevere:
            return .iconLevelHigh
        case .pbqHigh, .cesDDepression, .pdsSevere:
            return .iconLevelSevere
        }
    }

    var scoreColor: Color {
        switch self {
        case .pbqLow, .cesDNormal, .pdsMild:
            return Color(.pawPrimary)
        case .pbqAverage, .pdsModerate:
            return Color(.pawWarning)
        case .cesDHighRisk, .pdsModerateToSevere:
            return Color(.accent)
        case .pbqHigh, .cesDDepression, .pdsSevere:
            return Color(.danger)
        }
    }

    var badgeBackground: Color { scoreColor.opacity(0.15) }

    
    var cardGradient: EllipticalGradient {
        switch self {
        case .pbqLow, .cesDNormal, .pdsMild:
            return EllipticalGradient(
                colors: [Color(.pawPrimary).opacity(0.15), .gray0],
                center: .center,
                startRadiusFraction: 0,
                endRadiusFraction: 0.5
            )
        case .pbqAverage, .pdsModerate:
            return EllipticalGradient(
                colors: [Color(.pawWarning).opacity(0.15), .gray0],
                center: .center,
                startRadiusFraction: 0,
                endRadiusFraction: 0.5
            )
        case .cesDHighRisk, .pdsModerateToSevere:
            return EllipticalGradient(
                colors: [Color(.accent).opacity(0.15), .gray0],
                center: .center,
                startRadiusFraction: 0,
                endRadiusFraction: 0.5
            )
        case .pbqHigh, .cesDDepression, .pdsSevere:
            return EllipticalGradient(
                colors: [Color(.danger).opacity(0.15), .gray0],
                center: .center,
                startRadiusFraction: 0,
                endRadiusFraction: 0.5
            )
        }
    }
    
    
}

// MARK: - Interpretation Row Model

struct AssessmentInterpretationRow: Equatable {
    let level: AssessmentScoreLevel
}

// MARK: - State

@ObservableState
struct SelfAssessmentResultState: Equatable {
    var navBar = NavigationBarState(
        title: "검사 결과",
        leftButton: .none,
        rightButton: .close
    )
    var assessmentType: AssessmentType = .pbq
    var score: Int = 30
    var hasHistory: Bool = false
    var historyState: AssessmentHistoryState = .noRecord
    var maxScore: Int { assessmentType.maxScore }
    var testTitle: String { assessmentType.title }
    var scoreLevel: AssessmentScoreLevel { assessmentType.scoreLevel(for: score) }
    var interpretationRows: [AssessmentInterpretationRow] { assessmentType.interpretationRows }
}

// MARK: - Action

@CasePathable
enum SelfAssessmentResultAction: Equatable {
    case navBar(NavigationBarAction)
}

// MARK: - Reducer

struct SelfAssessmentResultFeature: Reducer {
    var body: some Reducer<SelfAssessmentResultState, SelfAssessmentResultAction> {
        Scope(state: \.navBar, action: \.navBar) {
            NavigationBarReducer()
        }
        Reduce { state, action in
            switch action {
            case .navBar:
                return .none
            }
        }
    }
}
