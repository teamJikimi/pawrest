//
//  SelfAssessmentFeature.swift
//  pawrest
//
//  Created by Moon AYoung on 6/16/26.
//

import Foundation
import ComposableArchitecture

@ObservableState
struct SelfAssessmentState: Equatable {
    let type: SelfAssessmentType
    let questions: [SelfAssessmentQuestion]
    
    var answers: [Int?]
    var showExitAlert: Bool = false
    var shouldDismiss: Bool = false
    
    var firstUnansweredIndex: Int? {
        answers.firstIndex(where: { $0 == nil })
    }
    
    init(type: SelfAssessmentType) {
        self.type = type
        self.questions = SelfAssessmentData.questions(for: type)
        self.answers = Array(repeating: nil, count: self.questions.count)
    }
}

@CasePathable
enum SelfAssessmentAction: Equatable {
    case optionSelected(questionIndex: Int, optionIndex: Int)
    case submitTapped
    case scrollToUnanswered
    
    case backButtonTapped
    case exitAlertConfirmed
    case exitAlertCancelled
}

// MARK: - Reducer

struct SelfAssessmentReducer: Reducer {
    var body: some Reducer<SelfAssessmentState, SelfAssessmentAction> {
        Reduce { state, action in
            switch action {
            case .optionSelected(let questionIndex, let optionIndex):
                state.answers[questionIndex] = optionIndex
                return .none
                
            case .submitTapped:
                if state.firstUnansweredIndex != nil {
                    return .send(.scrollToUnanswered)
                }
                //결과화면 연결
                return .none
                
            case .scrollToUnanswered:
                return .none
                
            case .backButtonTapped:
                state.showExitAlert = true
                return .none
                
            case .exitAlertConfirmed:
                state.showExitAlert = false
                state.shouldDismiss = true
                return .none
                
            case .exitAlertCancelled:
                state.showExitAlert = false
                return .none
            }
        }
    }
}
