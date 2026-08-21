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
        _ postID: String,
        _ authorID: String,
        _ authorName: String,
        _ title: String,
        _ content: String,
        _ imageURLs: [String]
    ) async throws -> Post
    
    var uploadImages: @Sendable (
        _ postID: String,
        _ imageDatas: [Data]
    ) async throws -> [String]
    
    var deletePost: @Sendable (
        _ postID: String,
        _ imageURLs: [String]
    ) async throws -> Void
    
    var updatePost: @Sendable (
        _ post: Post,
        _ newImageDatas: [Data]
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
    ) async throws -> [Comment]

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

                            let commentDTOs = try await service.fetchComments(
                                postID: post.id
                            )

                            let topLevelDTOs = commentDTOs.filter {
                                $0.parentCommentID == nil
                            }

                            post.comments = topLevelDTOs.map { parentDTO in
                                let replies = commentDTOs
                                    .filter {
                                        $0.parentCommentID == parentDTO.id
                                    }
                                    .map {
                                        $0.toDomain()
                                    }

                                return parentDTO.toDomain(
                                    replies: replies
                                )
                            }

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
            
            uploadImages: { postID, imageDatas in
                let storageService = FirebaseStorageService()
                var urls: [String] = []
                
                for imageData in imageDatas {
                    let entity = ImageUploadEntity(
                        data: imageData,
                        fileExtension: "jpg"
                    )
                    let url = try await storageService.upload(
                        image: entity,
                        to: .community(
                            postID: postID,
                            imageID: UUID().uuidString
                        )
                    )
                    urls.append(url)
                }
                
                return urls
            },
            
            deletePost: { postID, imageURLs in
                try await service.deletePost(postID: postID)
                try? await service.deletePostImages(imageURLs: imageURLs)
            },
            
            updatePost: { post, newImageDatas in
                let storageService = FirebaseStorageService()
                var imageURLs = post.imageURLs
                
                if !newImageDatas.isEmpty {
                    var newURLs: [String] = []
                    for imageData in newImageDatas {
                        let entity = ImageUploadEntity(
                            data: imageData,
                            fileExtension: "jpg"
                        )
                        let url = try await storageService.upload(
                            image: entity,
                            to: .community(
                                postID: post.id,
                                imageID: UUID().uuidString
                            )
                        )
                        newURLs.append(url)
                    }
                    imageURLs = newURLs
                }
                
                try await service.updatePost(
                    postID: post.id,
                    title: post.title,
                    content: post.content,
                    imageURLs: imageURLs
                )
                
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
                let dtos = try await service.fetchComments(
                    postID: postID
                )

                let topLevelDTOs = dtos.filter {
                    $0.parentCommentID == nil
                }

                return topLevelDTOs.map { parentDTO in
                    let replies = dtos
                        .filter {
                            $0.parentCommentID == parentDTO.id
                        }
                        .map {
                            $0.toDomain()
                        }

                    return parentDTO.toDomain(
                        replies: replies
                    )
                }
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
