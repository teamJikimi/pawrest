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
    
    var navigationBar = NavigationBarState(
        title: "",
        leftButton: .back,
        rightButton: .none,
        backgroundColor: .gray10
    )
    
    var answers: [Int?]
    var showExitAlert: Bool = false
    var shouldDismiss: Bool = false
    
    var firstUnansweredIndex: Int? {
        answers.firstIndex(where: { $0 == nil })
    }
    
    var scrollTargetIndex: Int? = nil
    
    var isResultPresented: Bool = false
    var totalScore: Int? = nil
    
    init(type: SelfAssessmentType) {
        self.type = type
        self.questions = SelfAssessmentData.questions(for: type)
        self.answers = Array(repeating: nil, count: self.questions.count)
    }
}

// MARK: - Action

@CasePathable
enum SelfAssessmentAction: Equatable {
    case optionSelected(questionIndex: Int, optionIndex: Int)
    case submitTapped
    case scrollToUnanswered
    
    case backButtonTapped
    case exitAlertConfirmed
    case exitAlertCancelled
    
    case navigationBar(NavigationBarAction)
    
    case resultDismissed
}

// MARK: - Reducer

struct SelfAssessmentReducer: Reducer {
    var body: some Reducer<SelfAssessmentState, SelfAssessmentAction> {
        Scope(state: \.navigationBar, action: \.navigationBar) {
            NavigationBarReducer()
        }
        
        Reduce { state, action in
            switch action {
            case .navigationBar(.leftButtonTapped):
                state.showExitAlert = true
                return .none
                
            case .navigationBar:
                return .none
                
            case .optionSelected(let questionIndex, let optionIndex):
                guard state.answers.indices.contains(questionIndex),
                      state.type.options.indices.contains(optionIndex)
                else { return .none }
                
                state.answers[questionIndex] = optionIndex
                return .none
                
            case .submitTapped:
                if state.firstUnansweredIndex != nil {
                    return .send(.scrollToUnanswered)
                }
                if let score = state.type.calculateScore(answers: state.answers) {
                    state.totalScore = score
                    state.isResultPresented = true
                }
                return .none
                
            case .scrollToUnanswered:
                state.scrollTargetIndex = state.firstUnansweredIndex
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
                
            case .resultDismissed:
                state.isResultPresented = false
                return .none
            }
        }
    }
}
