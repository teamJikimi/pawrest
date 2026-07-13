//
//  OnboardingPetProfileFeature.swift
//  pawrest
//
//  Created by Moon AYoung on 7/13/26.
//

import Foundation
import ComposableArchitecture

// MARK: - State

@ObservableState
struct OnboardingPetProfileState: Equatable {
    var navigationBar = NavigationBarState(
        title: "",
        leftButton: .back,
        rightButton: .none
    )
    
    var petName: String = ""
    var profileImage: Data? = nil
    
    var birthday: Date? = nil
    var deathDay: Date? = nil
    
    var showBirthdayPicker: Bool = false
    var showDeathDayPicker: Bool = false
    
    var shouldDismiss: Bool = false
    
    var birthdayText: String {
        guard let date = birthday else { return "" }
        return date.formattedOnboarding
    }
    
    var deathDayText: String {
        guard let date = deathDay else { return "" }
        return date.formattedOnboarding
    }
    
    var isNameValid: Bool {
        let trimmed = petName
        guard trimmed.count >= 2 && trimmed.count <= 12 else { return false }
        let pattern = "^[가-힣a-zA-Z0-9]+$"
        return trimmed.range(of: pattern, options: .regularExpression) != nil
    }
    
    var nameHelper: OnboardingTextFieldHelper {
        .info("2~12자 · 한글/영문/숫자만 사용 가능해요")
    }
    
    var isNextEnabled: Bool {
        isNameValid
    }
}

// MARK: - Action

@CasePathable
enum OnboardingPetProfileAction: Equatable {
    case navigationBar(NavigationBarAction)
    
    case petNameChanged(String)
    case profileImageSelected(Data?)
    
    case birthdayFieldTapped
    case deathDayFieldTapped
    case birthdaySelected(Date)
    case deathDaySelected(Date)
    case pickerDismissed
    
    case nextTapped
}

// MARK: - Reducer

struct OnboardingPetProfileReducer: Reducer {
    var body: some Reducer<OnboardingPetProfileState, OnboardingPetProfileAction> {
        Scope(state: \.navigationBar, action: \.navigationBar) {
            NavigationBarReducer()
        }
        
        Reduce { state, action in
            switch action {
            case .navigationBar:
                return .none
                
            case .petNameChanged(let raw):
                let filtered = raw.filter { char in
                    let s = String(char)
                    return s.range(of: "^[가-힣ㄱ-ㅎㅏ-ㅣa-zA-Z0-9]$", options: .regularExpression) != nil
                }
                let clamped = String(filtered.prefix(12))
                state.petName = clamped
                return .none
                
            case .profileImageSelected(let data):
                state.profileImage = data
                return .none
                
            case .birthdayFieldTapped:
                state.showBirthdayPicker = true
                return .none
                
            case .deathDayFieldTapped:
                state.showDeathDayPicker = true
                return .none
                
            case .birthdaySelected(let date):
                state.birthday = date
                return .none
                
            case .deathDaySelected(let date):
                state.deathDay = date
                return .none
                
            case .pickerDismissed:
                state.showBirthdayPicker = false
                state.showDeathDayPicker = false
                return .none
                
            case .nextTapped:
                // TODO: SwiftData 저장 + 튜토리얼 화면 이동
                return .none
            }
        }
    }
}
