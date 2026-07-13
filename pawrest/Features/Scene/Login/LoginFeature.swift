//
//  LoginFeature.swift
//  pawrest
//
//  Created by 곽예리 on 7/9/26.
//

import Foundation
import ComposableArchitecture

@ObservableState
struct LoginState: Equatable {
    var isLoading = false
    var errorMessage: String?
}

@CasePathable
enum LoginAction: Equatable {
    case appleLoginButtonTapped
    case signInResponse(Result<AppleSignInEntity, AppleSignInErrorWrapper>)
}

struct AppleSignInErrorWrapper: Error, Equatable {
    let message: String
}

struct LoginReducer: Reducer {
    @Dependency(\.appleSignInClient) var appleSignInClient

    var body: some Reducer<LoginState, LoginAction> {
        Reduce { state, action in
            switch action {
            case .appleLoginButtonTapped:
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    do {
                        let entity = try await appleSignInClient.signIn()
                        await send(.signInResponse(.success(entity)))
                    } catch {
                        await send(.signInResponse(.failure(
                            AppleSignInErrorWrapper(message: error.localizedDescription)
                        )))
                    }
                }

            case .signInResponse(.success):
                state.isLoading = false
                // TODO: 프로필 설정 화면으로 이동
                return .none

            case .signInResponse(.failure):
                state.isLoading = false
                state.errorMessage = "로그인에 실패했습니다."
                return .none
            }
        }
    }
}
