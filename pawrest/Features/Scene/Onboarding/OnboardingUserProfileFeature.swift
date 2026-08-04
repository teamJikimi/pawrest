//
//  OnboardingUserProfileFeature.swift
//  pawrest
//
//  Created by Moon AYoung on 7/11/26.
//

import Foundation
import ComposableArchitecture

// MARK: - Nickname Status

enum NicknameStatus: Equatable {
    case idle
    case formatError
    case available
    case duplicated
    case checking
    
    var helper: OnboardingTextFieldHelper {
        switch self {
        case .idle:
            return .info("2~12자 · 한글/영문/숫자만 사용 가능해요")
        case .formatError:
            return .error("닉네임 형식이 올바르지 않습니다")
        case .available:
            return .success("사용할 수 있는 닉네임이에요")
        case .duplicated:
            return .error("이미 사용 중인 닉네임이에요")
        case .checking:
            return .info("확인중")
        }
    }
}

// MARK: - State

@ObservableState
struct OnboardingUserProfileState: Equatable {
    var navigationBar = NavigationBarState(
        title: "",
        leftButton: .back,
        rightButton: .none
    )
    
    var nickname: String = ""
    var nicknameStatus: NicknameStatus = .idle
    var profileImage: Data? = nil
    var isPetProfilePresented: Bool = false
    
    var isFormatValid: Bool {
        let trimmed = nickname
        guard trimmed.count >= 2 && trimmed.count <= 12 else { return false }
        let pattern = "^[가-힣a-zA-Z0-9]+$"
        return trimmed.range(of: pattern, options: .regularExpression) != nil
    }
    
    var isDuplicateCheckEnabled: Bool {
        isFormatValid && nicknameStatus != .checking && nicknameStatus != .available
    }
    
    var isNextEnabled: Bool {
        nicknameStatus == .available
    }
}

// MARK: - Action

@CasePathable
enum OnboardingUserProfileAction: Equatable {
    case navigationBar(NavigationBarAction)
    
    case nicknameChanged(String)
    case duplicateCheckTapped
    case duplicateCheckResult(isAvailable: Bool)
    case profileImageSelected(Data?)
    case nextTapped
    case petProfileDismissed
}

// MARK: - Reducer

struct OnboardingUserProfileReducer: Reducer {
    var body: some Reducer<OnboardingUserProfileState, OnboardingUserProfileAction> {
        
        Scope(state: \.navigationBar, action: \.navigationBar) {
            NavigationBarReducer()
        }
        
        Reduce { state, action in
            switch action {
            case .navigationBar:
                return .none

            case .nicknameChanged(let raw):
                let filtered = raw.filter { char in
                    let s = String(char)
                    return s.range(of: "^[가-힣ㄱ-ㅎㅏ-ㅣa-zA-Z0-9]$", options: .regularExpression) != nil
                }
                let clamped = String(filtered.prefix(12))
                state.nickname = clamped
                
                if state.nicknameStatus == .available || state.nicknameStatus == .duplicated {
                    state.nicknameStatus = .idle
                }
                
                return .none
                
            case .duplicateCheckTapped:
                guard state.isFormatValid else {
                    state.nicknameStatus = .formatError
                    return .none
                }
                state.nicknameStatus = .checking
                
                return .run { send in
                    try await Task.sleep(for: .milliseconds(500))
                    await send(.duplicateCheckResult(isAvailable: true))
                }
                
            case .duplicateCheckResult(let isAvailable):
                state.nicknameStatus = isAvailable ? .available : .duplicated
                return .none
                
            case .profileImageSelected(let data):
                state.profileImage = data
                return .none
                
            case .nextTapped:
                state.isPetProfilePresented = true
                return .none
                
            case .petProfileDismissed:
                state.isPetProfilePresented = false
                return .none
            }
        }
    }
}
