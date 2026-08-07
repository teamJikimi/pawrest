//
//  CommunityModel.swift
//  pawrest
//
//  Created by Moon AYoung on 5/27/26.
//

import Foundation

// MARK: - Author

struct Author: Equatable, Identifiable {
    let id: String
    let name: String
    let profileImageURL: String?

    init(
        id: String = UUID().uuidString,
        name: String,
        profileImageURL: String?
    ) {
        self.id = id
        self.name = name
        self.profileImageURL = profileImageURL
    }
}


//MARK: - Comment

struct Comment: Equatable, Identifiable {
    let id: UUID
    let content: String
    let author: Author
    let createdAt: Date
    var replies: [Comment]
    
    init(
        id: UUID = UUID(),
        content: String,
        author: Author,
        createdAt: Date,
        replies: [Comment] = []
        
    ) {
        self.id = id
        self.author = author
        self.content = content
        self.createdAt = createdAt
        self.replies = replies
    }
}

// MARK: - Post

struct Post: Equatable, Identifiable {
    let id: String
    let author: Author

    var title: String
    var content: String

    let createdAt: Date
    var imageURLs: [String]

    var likeCount: Int
    var isLiked: Bool
    var comments: [Comment]

    var commentCount: Int {
        comments.reduce(0) { $0 + 1 + $1.replies.count }
    }

    init(
        id: String = UUID().uuidString,
        author: Author,
        title: String,
        content: String,
        createdAt: Date,
        imageURLs: [String],
        likeCount: Int,
        isLiked: Bool,
        comments: [Comment]
    ) {
        self.id = id
        self.author = author
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.imageURLs = imageURLs
        self.likeCount = likeCount
        self.isLiked = isLiked
        self.comments = comments
    }
}
