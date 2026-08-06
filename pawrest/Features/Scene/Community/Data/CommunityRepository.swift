//
//  CommunityRepository.swift
//  pawrest
//
//  Created by Moon AYoung on 8/6/26.
//

import ComposableArchitecture
import Foundation

struct CommunityRepository {
    var fetchPosts: @Sendable (
        _ userID: String
    ) async throws -> [Post]

    var createPost: @Sendable (
        _ authorID: String,
        _ authorName: String,
        _ title: String,
        _ content: String
    ) async throws -> Post
    
    var deletePost: @Sendable (_ postID: String) async throws -> Void
    
    var updatePost: @Sendable (_ post: Post) async throws -> Post
    
    var isPostLiked: @Sendable (
        _ postID: String,
        _ userID: String
    ) async throws -> Bool

    var toggleLike: @Sendable (
        _ postID: String,
        _ userID: String,
        _ isLiked: Bool
    ) async throws -> Void
    
}

// MARK: - DependencyKey

extension CommunityRepository: DependencyKey {

    static let liveValue: CommunityRepository = {
        let service = CommunityFirestoreService()

        return CommunityRepository(
            fetchPosts: { userID in
                let postDTOs = try await service.fetchPosts()
                return try await withThrowingTaskGroup(
                    of: Post.self
                ) { group in
                    for dto in postDTOs {
                        group.addTask {
                            var post = dto.toDomain()

                            post.isLiked = try await service.isPostLiked(
                                postID: post.id,
                                userID: userID
                            )
                            return post
                        }
                    }
                    var posts: [Post] = []

                    for try await post in group {
                        posts.append(post)
                    }
                    return posts.sorted {
                        $0.createdAt > $1.createdAt
                    }
                }
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
            },
            updatePost: { post in
                try await service.updatePost(
                    postID: post.id,
                    title: post.title,
                    content: post.content
                )
                return post
            },
            isPostLiked: { postID, userID in
                try await service.isPostLiked(
                    postID: postID,
                    userID: userID
                )
            },

            toggleLike: { postID, userID, isLiked in
                try await service.toggleLike(
                    postID: postID,
                    userID: userID,
                    isLiked: isLiked
                )
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
