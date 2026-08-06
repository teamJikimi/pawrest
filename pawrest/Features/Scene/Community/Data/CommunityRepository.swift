//
//  CommunityRepository.swift
//  pawrest
//
//  Created by Moon AYoung on 8/6/26.
//

import ComposableArchitecture
import Foundation

struct CommunityRepository {

    var fetchPosts: @Sendable () async throws -> [Post]
}

// MARK: - DependencyKey

extension CommunityRepository: DependencyKey {

    static let liveValue: CommunityRepository = {

        let service = CommunityFirestoreService()

        return CommunityRepository(
            fetchPosts: {
                let postDTOs = try await service.fetchPosts()

                return postDTOs.map {
                    $0.toDomain()
                }
            }
        )
    }()
}

// MARK: - DependencyValues

extension DependencyValues {

    var communityRepository: CommunityRepository {
        get { self[CommunityRepository.self] }
        set { self[CommunityRepository.self] = newValue }
    }
}
