//
//  CommunityRepository.swift
//  pawrest
//
//  Created by Moon AYoung on 8/6/26.
//

import ComposableArchitecture
import Foundation

enum PostImagePayload: Equatable, Sendable {
    case remote(url: String)
    case local(data: Data)
}

struct CommunityRepository {
    var fetchPosts: @Sendable (
        _ userID: String
    ) async throws -> [Post]

    var createPost: @Sendable (
        _ postID: String,
        _ authorID: String,
        _ authorName: String,
        _ title: String,
        _ content: String,
        _ imageURLs: [String]
    ) async throws -> Post
    
    var uploadImages: @Sendable (
        _ authorID: String,
        _ postID: String,
        _ imageDatas: [Data]
    ) async throws -> [String]
    
    var deletePost: @Sendable (
        _ postID: String,
        _ imageURLs: [String]
    ) async throws -> Void
    
    var updatePost: @Sendable (
        _ post: Post,
        _ images: [PostImagePayload]
    ) async throws -> Post
    
    var isPostLiked: @Sendable (
        _ postID: String,
        _ userID: String
    ) async throws -> Bool

    var toggleLike: @Sendable (
        _ postID: String,
        _ userID: String,
        _ isLiked: Bool
    ) async throws -> Void
    
    var fetchComments: @Sendable (
        _ postID: String
    ) async throws -> [CommunityCommentDTO]

    var createComment: @Sendable (
        _ postID: String,
        _ authorID: String,
        _ authorName: String,
        _ content: String,
        _ parentCommentID: UUID?
    ) async throws -> Comment

    var deleteComment: @Sendable (
        _ postID: String,
        _ commentID: UUID
    ) async throws -> Void
    
    var fetchCommentedPostIDs: @Sendable (
        _ postIDs: [String],
        _ userID: String
    ) async throws -> Set<String>

    var updateComment: @Sendable (
        _ postID: String,
        _ commentID: UUID,
        _ content: String
    ) async throws -> Void

    var createReport: @Sendable (
        _ reporterID: String,
        _ targetType: String,
        _ targetID: String,
        _ targetAuthorID: String,
        _ reason: String
    ) async throws -> Void

    var blockUser: @Sendable (
        _ currentUserID: String,
        _ blockedUserID: String,
        _ blockedUserName: String
    ) async throws -> Void

    var unblockUser: @Sendable (
        _ currentUserID: String,
        _ blockedUserID: String
    ) async throws -> Void

    var fetchBlockedUserIDs: @Sendable (
        _ currentUserID: String
    ) async throws -> Set<String>
    
    var fetchBlockedUsers: @Sendable (
        _ currentUserID: String
    ) async throws -> [(id: String, name: String)]
    
    var deleteAllPostsByUser: @Sendable (
        _ authorID: String
    ) async throws -> Void
}

// MARK: - DependencyKey

extension CommunityRepository: DependencyKey {

    static let liveValue: CommunityRepository = {
        let service = CommunityFirestoreService()

        return CommunityRepository(
            
            fetchPosts: { userID in
                let postDTOs = try await service.fetchPosts()
                
                let profileService = await MainActor.run { UserProfileRemoteService() }
                let profiles = try await profileService.fetchProfiles(
                    userIDs: Array(Set(postDTOs.map { $0.authorID }))
                )
                
                let posts = try await withThrowingTaskGroup(of: Post.self) { group in
                    for dto in postDTOs {
                        group.addTask {
                            var post = dto.toDomain(profile: profiles[dto.authorID])
                            post.isLiked = try await service.isPostLiked(
                                postID: post.id,
                                userID: userID
                            )
                            return post
                        }
                    }
                    
                    var results: [Post] = []
                    for try await post in group {
                        results.append(post)
                    }
                    return results
                }
                
                return posts.sorted { $0.createdAt > $1.createdAt }
            },
            
            createPost: { postID, authorID, authorName, title, content, imageURLs in
                let postDTO = try await service.createPost(
                    postID: postID,
                    authorID: authorID,
                    authorName: authorName,
                    title: title,
                    content: content,
                    imageURLs: imageURLs
                )
                return postDTO.toDomain()
            },
            
            uploadImages: { authorID, postID, imageDatas in
                let uploaded = try await uploadCommunityImages(
                    imageDatas.enumerated().map { (index: $0.offset, data: $0.element) },
                    authorID: authorID,
                    postID: postID,
                    storageService: FirebaseStorageService()
                )
                return imageDatas.indices.compactMap { uploaded[$0] }
            },
            
            deletePost: { postID, imageURLs in
                try await service.deletePost(postID: postID)
                await FirebaseStorageService().delete(urls: imageURLs)
            },
            
            updatePost: { post, images in
                let storageService = FirebaseStorageService()
                
                let localItems: [(index: Int, data: Data)] = images
                    .enumerated()
                    .compactMap { index, image in
                        guard case .local(let data) = image else { return nil }
                        return (index: index, data: data)
                    }
                
                let uploaded = try await uploadCommunityImages(
                    localItems,
                    authorID: post.author.id,
                    postID: post.id,
                    storageService: storageService
                )
                
                let imageURLs: [String] = images
                    .enumerated()
                    .compactMap { index, image in
                        switch image {
                        case .remote(let url): return url
                        case .local: return uploaded[index]
                        }
                    }
                
                do {
                    try await service.updatePost(
                        postID: post.id,
                        title: post.title,
                        content: post.content,
                        imageURLs: imageURLs
                    )
                } catch {
                    await storageService.delete(urls: Array(uploaded.values))
                    throw error
                }
                
                let removedURLs = post.imageURLs.filter { !imageURLs.contains($0) }
                await storageService.delete(urls: removedURLs)
                
                var updated = post
                updated.imageURLs = imageURLs
                return updated
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
            },

            fetchComments: { postID in
                try await service.fetchComments(postID: postID)
            },

            createComment: {
                postID,
                authorID,
                authorName,
                content,
                parentCommentID in

                let dto = try await service.createComment(
                    postID: postID,
                    authorID: authorID,
                    authorName: authorName,
                    content: content,
                    parentCommentID: parentCommentID
                )

                return dto.toDomain()
            },

            deleteComment: { postID, commentID in
                try await service.deleteComment(
                    postID: postID,
                    commentID: commentID
                )
            },
            
            fetchCommentedPostIDs: { postIDs, userID in
                try await withThrowingTaskGroup(of: String?.self) { group in
                    for postID in postIDs {
                        group.addTask {
                            try await service.hasComment(postID: postID, authorID: userID)
                                ? postID
                                : nil
                        }
                    }
                    
                    var result: Set<String> = []
                    for try await postID in group {
                        if let postID { result.insert(postID) }
                    }
                    return result
                }
            },

            updateComment: { postID, commentID, content in
                try await service.updateComment(
                    postID: postID,
                    commentID: commentID,
                    content: content
                )
            },
            
            createReport: { reporterID, targetType, targetID, targetAuthorID, reason in
                try await service.createReport(
                    reporterID: reporterID,
                    targetType: targetType,
                    targetID: targetID,
                    targetAuthorID: targetAuthorID,
                    reason: reason
                )
            },

            blockUser: { currentUserID, blockedUserID, blockedUserName in
                try await service.blockUser(
                    currentUserID: currentUserID,
                    blockedUserID: blockedUserID,
                    blockedUserName: blockedUserName
                )
            },

            unblockUser: { currentUserID, blockedUserID in
                try await service.unblockUser(
                    currentUserID: currentUserID,
                    blockedUserID: blockedUserID
                )
            },

            fetchBlockedUserIDs: { currentUserID in
                try await service.fetchBlockedUserIDs(
                    currentUserID: currentUserID
                )
            },
            
            fetchBlockedUsers: { currentUserID in
                try await service.fetchBlockedUsers(currentUserID: currentUserID)
            },
            
            deleteAllPostsByUser: { authorID in
                try await service.deleteAllPostsByUser(authorID: authorID)
            }
        )
    }()
}

// MARK: - Image Upload

private func uploadCommunityImages(
    _ items: [(index: Int, data: Data)],
    authorID: String,
    postID: String,
    storageService: FirebaseStorageService
) async throws -> [Int: String] {
    var uploaded: [Int: String] = [:]
    
    do {
        try await withThrowingTaskGroup(of: (Int, String).self) { group in
            for item in items {
                group.addTask {
                    let url = try await storageService.upload(
                        image: ImageUploadEntity(data: item.data, fileExtension: "jpg"),
                        to: .community(
                            userId: authorID,
                            postID: postID,
                            imageID: UUID().uuidString
                        )
                    )
                    return (item.index, url)
                }
            }
            
            for try await (index, url) in group {
                uploaded[index] = url
            }
        }
    } catch {
        await storageService.delete(urls: Array(uploaded.values))
        throw error
    }
    
    return uploaded
}

// MARK: - DependencyValues

extension DependencyValues {
    var communityRepository: CommunityRepository {
        get { self[CommunityRepository.self] }
        set { self[CommunityRepository.self] = newValue }
    }
}
