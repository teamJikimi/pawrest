//
//  UserProfileRemoteClient.swift
//  pawrest
//
//  Created by Moon Ayoung on 9/15/26.
//

import Foundation
import ComposableArchitecture

struct UserProfileRemoteClient {
    var fetchProfiles: @Sendable (
        _ userIDs: [String]
    ) async throws -> [String: RemoteUserProfile]
    
    var createProfileIfNeeded: @Sendable (
        _ userID: String,
        _ nickname: String,
        _ imageData: Data?
    ) async throws -> Void
    
    var updateProfile: @Sendable (
        _ userID: String,
        _ nickname: String,
        _ imageData: Data?,
        _ isImageChanged: Bool
    ) async throws -> Void
    
    var deleteProfile: @Sendable (
        _ userID: String
    ) async throws -> Void
}

// MARK: - DependencyKey

extension UserProfileRemoteClient: DependencyKey {
    
    static let liveValue: UserProfileRemoteClient = {
        let service = UserProfileRemoteService()
        
        return UserProfileRemoteClient(
            fetchProfiles: { userIDs in
                try await service.fetchProfiles(userIDs: userIDs)
            },
            
            createProfileIfNeeded: { userID, nickname, imageData in
                try await service.createProfileIfNeeded(
                    userID: userID,
                    nickname: nickname,
                    imageData: imageData
                )
            },
            
            updateProfile: { userID, nickname, imageData, isImageChanged in
                try await service.updateProfile(
                    userID: userID,
                    nickname: nickname,
                    imageData: imageData,
                    isImageChanged: isImageChanged
                )
            },
            
            deleteProfile: { userID in
                try await service.deleteProfile(userID: userID)
            }
        )
    }()
}

// MARK: - DependencyValues

extension DependencyValues {
    var userProfileRemoteClient: UserProfileRemoteClient {
        get { self[UserProfileRemoteClient.self] }
        set { self[UserProfileRemoteClient.self] = newValue }
    }
}
