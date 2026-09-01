//
//  BlockedListFeature.swift
//  pawrest
//
//  Created by 소은 on 6/6/26.
//

import ComposableArchitecture

struct BlockedListFeature: Reducer {
    
    // MARK: - State
    
    @ObservableState
    struct State: Equatable {
        var navigationBar: NavigationBarState = NavigationBarState(
            title: "차단 목록",
            leftButton: .back,
            rightButton: .none
        )
        
        var blockedUsers: [(id: String, name: String)] = []
        var isLoading: Bool = false
        var shouldDismiss: Bool = false
        
        static func == (lhs: State, rhs: State) -> Bool {
            lhs.navigationBar == rhs.navigationBar
            && lhs.blockedUsers.count == rhs.blockedUsers.count
            && lhs.isLoading == rhs.isLoading
            && lhs.shouldDismiss == rhs.shouldDismiss
            && zip(lhs.blockedUsers, rhs.blockedUsers).allSatisfy {
                $0.id == $1.id && $0.name == $1.name
            }
        }
    }
    
    // MARK: - Action
    
    @CasePathable
    enum Action: Equatable {
        case navigationBar(NavigationBarAction)
        case onAppear
        case blockedUsersLoaded([(id: String, name: String)])
        case unblockTapped(userID: String)
        case unblockResponse(userID: String, success: Bool)
        
        static func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.navigationBar(let a), .navigationBar(let b)):
                return a == b
            case (.onAppear, .onAppear):
                return true
            case (.blockedUsersLoaded(let a), .blockedUsersLoaded(let b)):
                return a.count == b.count
                    && zip(a, b).allSatisfy { $0.id == $1.id && $0.name == $1.name }
            case (.unblockTapped(let a), .unblockTapped(let b)):
                return a == b
            case (.unblockResponse(let aID, let aSuccess), .unblockResponse(let bID, let bSuccess)):
                return aID == bID && aSuccess == bSuccess
            default:
                return false
            }
        }
    }
    
    // MARK: - Dependencies
    
    @Dependency(\.communityRepository) var communityRepository
    @Dependency(\.authSessionClient) var authSessionClient
    
    // MARK: - Reducer
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .navigationBar(.leftButtonTapped):
            state.shouldDismiss = true
            return .none
            
        case .navigationBar:
            return .none
            
        case .onAppear:
            guard let userID = authSessionClient.currentUserID() else {
                return .none
            }
            state.isLoading = true
            
            return .run { send in
                let users = try await communityRepository
                    .fetchBlockedUsers(userID)
                await send(.blockedUsersLoaded(users))
            }
            
        case .blockedUsersLoaded(let users):
            state.isLoading = false
            state.blockedUsers = users
            return .none
            
        case .unblockTapped(let userID):
            guard let currentUserID = authSessionClient.currentUserID() else {
                return .none
            }
            
            return .run { send in
                do {
                    try await communityRepository.unblockUser(
                        currentUserID, userID
                    )
                    await send(.unblockResponse(userID: userID, success: true))
                } catch {
                    await send(.unblockResponse(userID: userID, success: false))
                }
            }
            
        case .unblockResponse(let userID, let success):
            if success {
                state.blockedUsers.removeAll { $0.id == userID }
            }
            return .none
        }
    }
}
