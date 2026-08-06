//
//  CommunityFirestoreService.swift
//  pawrest
//
//  Created by Moon AYoung on 8/6/26.
//

import Foundation
import FirebaseFirestore

final class CommunityFirestoreService {

    private let firestore: Firestore

    init(
        firestore: Firestore = Firestore.firestore()
    ) {
        self.firestore = firestore
    }

    func fetchPosts() async throws -> [CommunityPostDTO] {

        let snapshot = try await firestore
            .collection("posts")
            .order(by: "createdAt", descending: true)
            .getDocuments()

        return snapshot.documents.compactMap {
            CommunityPostDTO(document: $0)
        }
    }
}
