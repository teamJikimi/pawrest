//
//  CommunityModel.swift
//  pawrest
//
//  Created by Moon AYoung on 5/27/26.
//

import Foundation

//MARK: - Author

struct Author: Equatable, Identifiable {
    let id: UUID
    let name: String
    let profileImageURL: String?
    
    init(
        id: UUID = UUID(),
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

//MARK: - Post

struct Post: Equatable, Identifiable {
    let id: UUID
    let author: Author
    let title: String
    let content: String
    let createdAt: Date
    let imageURLs: [String]
    
    var likeCount: Int
    var isLiked: Bool
    var comments: [Comment]
    
    var commentCount: Int {
        comments.reduce(0) { $0 + 1 + $1.replies.count }
    }
    
    init(
        id: UUID = UUID(),
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

// MARK: - Dummy

enum CommunityDummy {
    static let currentUserID = UUID()
    
    private static let dummyUser1ID = UUID()
    private static let dummyUser2ID = UUID()
    private static let dummyUser3ID = UUID()
    
    static var posts: [Post] {
        [
            
            Post(
                author: Author(id: currentUserID, name: "나", profileImageURL: nil),
                title: "우리 아이 보낸 지 한 달이 되었어요",
                content: "시간이 지나면 나아질 줄 알았는데, 아직도 현관문 앞에서 발소리를 기다리게 돼요. 같은 경험 있으신 분 계실까요?",
                createdAt: Date().addingTimeInterval(-86400),
                imageURLs: [],
                likeCount: 8,
                isLiked: false,
                comments: [
                    Comment(
                        content: "저도 같은 마음이에요. 시간이 약이라고 하지만 쉽지 않죠.",
                        author: Author(id: dummyUser1ID, name: "뭉치", profileImageURL: nil),
                        createdAt: Date().addingTimeInterval(-80000)
                    )
                ]
            ),
            Post(
                author: Author(id: currentUserID, name: "나", profileImageURL: nil),
                title: "강아지 사료 추천 부탁드려요",
                content: "10살 노견인데 신장 수치가 안 좋아져서 신장 케어 사료를 찾고 있어요. 혹시 좋은 사료 아시는 분 계신가요?",
                createdAt: Date().addingTimeInterval(-172800),
                imageURLs: [],
                likeCount: 3,
                isLiked: false,
                comments: []
            ),
            Post(
                author: Author(id: currentUserID, name: "나", profileImageURL: nil),
                title: "무지개다리를 건넌 우리 콩이",
                content: "13년을 함께한 콩이가 어제 무지개다리를 건넜어요. 마지막까지 꼬리를 흔들어주던 모습이 잊혀지지 않아요.",
                createdAt: Date().addingTimeInterval(-259200),
                imageURLs: [
                    "https://picsum.photos/seed/pawrest_my1/400/400",
                    "https://picsum.photos/seed/pawrest_my2/400/400"
                ],
                likeCount: 42,
                isLiked: false,
                comments: [
                    Comment(
                        content: "콩이가 정말 행복했을 거예요. 힘내세요.",
                        author: Author(id: dummyUser2ID, name: "별이아빠", profileImageURL: nil),
                        createdAt: Date().addingTimeInterval(-250000)
                    )
                ]
            ),
            
            
            Post(
                author: Author(id: dummyUser1ID, name: "뭉치", profileImageURL: nil),
                title: "오늘따라 더 보고 싶은 날이에요",
                content: "아무것도 아닌 시간에 갑자기 생각나서요. 이런 날엔 여기 와서 얘기하게 되네요.",
                createdAt: Date().addingTimeInterval(-3600),
                imageURLs: [],
                likeCount: 12,
                isLiked: true,
                comments: [
                    Comment(
                        content: "저도요. 같이 힘내요.",
                        author: Author(id: dummyUser3ID, name: "초코맘", profileImageURL: nil),
                        createdAt: Date().addingTimeInterval(-3000)
                    )
                ]
            ),
            Post(
                author: Author(id: dummyUser2ID, name: "별이아빠", profileImageURL: nil),
                title: "산책 사진 정리하다가",
                content: "같이 자주 가던 동네 카페 앞을 지나갔는데 괜히 발이 안 떨어지더라고요. 거기서 항상 테라스에 앉아서 물 한 그릇 시켜줬었는데.",
                createdAt: Date().addingTimeInterval(-7200),
                imageURLs: [
                    "https://picsum.photos/seed/pawrest_liked1/400/400",
                    "https://picsum.photos/seed/pawrest_liked2/400/400"
                ],
                likeCount: 25,
                isLiked: true,
                comments: []
            ),
            
            
            Post(
                author: Author(id: dummyUser3ID, name: "초코맘", profileImageURL: nil),
                title: "첫 기일을 보내고 나서",
                content: "초코의 첫 기일이었어요. 좋아하던 간식을 사다놓고 한참을 울었네요. 보고 싶다, 우리 초코.",
                createdAt: Date().addingTimeInterval(-14400),
                imageURLs: [],
                likeCount: 31,
                isLiked: false,
                comments: [
                    Comment(
                        content: "초코도 분명 좋아했을 거예요. 힘내세요.",
                        author: Author(id: currentUserID, name: "나", profileImageURL: nil),
                        createdAt: Date().addingTimeInterval(-13000)
                    )
                ]
            ),
            Post(
                author: Author(id: dummyUser1ID, name: "뭉치", profileImageURL: nil),
                title: "반려동물 상실 상담 후기",
                content: "상담을 받아볼까 고민하다가 용기내서 다녀왔어요. 아직 많이 울지만, 조금은 마음이 편해진 것 같아요.",
                createdAt: Date().addingTimeInterval(-28800),
                imageURLs: [
                    "https://picsum.photos/seed/pawrest_comment1/400/400"
                ],
                likeCount: 56,
                isLiked: false,
                comments: [
                    Comment(
                        content: "저도 상담 생각 중인데 용기가 안 나요. 어떤 곳에서 받으셨나요?",
                        author: Author(id: currentUserID, name: "나", profileImageURL: nil),
                        createdAt: Date().addingTimeInterval(-27000)
                    ),
                    Comment(
                        content: "펫로스 전문 상담센터에서 받았어요. 도움이 많이 됐어요.",
                        author: Author(id: dummyUser1ID, name: "뭉치", profileImageURL: nil),
                        createdAt: Date().addingTimeInterval(-26000)
                    )
                ]
            )
        ]
    }
}
