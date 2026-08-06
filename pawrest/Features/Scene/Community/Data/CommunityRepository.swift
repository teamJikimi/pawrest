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

    var createPost: @Sendable (
        _ authorID: String,
        _ authorName: String,
        _ title: String,
        _ content: String
    ) async throws -> Post
    
    var deletePost: @Sendable (_ postID: String) async throws -> Void
}

// MARK: - DependencyKey

extension CommunityRepository: DependencyKey {

    static let liveValue: CommunityRepository = {
        let service = CommunityFirestoreService()

        return CommunityRepository(
            fetchPosts: {
                let postDTOs = try await service.fetchPosts()
                return postDTOs.map { $0.toDomain() }
            },
            createPost: { authorID, authorName, title, content in
                let postDTO = try await service.createPost(
                    authorID: authorID,
                    authorName: authorName,
                    title: title,
                    content: content
                )
                return postDTO.toDomain()
            },
            deletePost: { postID in
                try await service.deletePost(postID: postID)
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
