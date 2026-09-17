//
//  UserProfileRemoteService.swift
//  pawrest
//
//  Created by Moon Ayoung on 9/15/26.
//

import Foundation
import UIKit
import FirebaseFirestore

struct RemoteUserProfile: Equatable {
    let id: String
    let nickname: String
    let profileImageURL: String?
}

final class UserProfileRemoteService {
    
    private let firestore: Firestore
    private let storageService: FirebaseStorageServiceProtocol
    
    private let inQueryLimit = 30
    private let profileImageMaxDimension: CGFloat = 1024
    
    init(
        firestore: Firestore = Firestore.firestore(),
        storageService: FirebaseStorageServiceProtocol = FirebaseStorageService()
    ) {
        self.firestore = firestore
        self.storageService = storageService
    }
    
    // MARK: - Fetch
    
    func fetchProfiles(userIDs: [String]) async throws -> [String: RemoteUserProfile] {
        let uniqueIDs = Array(Set(userIDs))
        guard !uniqueIDs.isEmpty else { return [:] }
        
        var profiles: [String: RemoteUserProfile] = [:]
        
        for start in stride(from: 0, to: uniqueIDs.count, by: inQueryLimit) {
            let chunk = Array(uniqueIDs[start..<min(start + inQueryLimit, uniqueIDs.count)])
            
            let snapshot = try await firestore
                .collection("users")
                .whereField(FieldPath.documentID(), in: chunk)
                .getDocuments()
            
            for document in snapshot.documents {
                guard let profile = RemoteUserProfile(document: document) else { continue }
                profiles[profile.id] = profile
            }
        }
        
        return profiles
    }
    
    // MARK: - Create
    
    func createProfileIfNeeded(
        userID: String,
        nickname: String,
        imageData: Data?
    ) async throws {
        let snapshot = try await userDocument(userID).getDocument()
        guard !snapshot.exists else { return }
        
        try await createProfile(userID: userID, nickname: nickname, imageData: imageData)
    }
    
    // MARK: - Update
    
    func updateProfile(
        userID: String,
        nickname: String,
        imageData: Data?,
        isImageChanged: Bool
    ) async throws {
        let snapshot = try await userDocument(userID).getDocument()
        
        guard snapshot.exists else {
            try await createProfile(userID: userID, nickname: nickname, imageData: imageData)
            return
        }
        
        guard isImageChanged else {
            try await userDocument(userID).updateData([
                "nickname": nickname,
                "updatedAt": FieldValue.serverTimestamp()
            ])
            return
        }
        
        let oldImageURL = snapshot.data()?["profileImageURL"] as? String
        let newImageURL = try await uploadProfileImage(userID: userID, imageData: imageData)
        
        do {
            try await userDocument(userID).updateData([
                "nickname": nickname,
                "profileImageURL": newImageURL ?? NSNull(),
                "updatedAt": FieldValue.serverTimestamp()
            ])
        } catch {
            if let newImageURL {
                try? await storageService.delete(url: newImageURL)
            }
            throw error
        }
        
        if let oldImageURL {
            try? await storageService.delete(url: oldImageURL)
        }
    }
    
    // MARK: - Delete
    
    func deleteProfile(userID: String) async throws {
        let snapshot = try await userDocument(userID).getDocument()
        guard snapshot.exists else { return }
        
        let imageURL = snapshot.data()?["profileImageURL"] as? String
        
        try await userDocument(userID).delete()
        
        if let imageURL {
            try? await storageService.delete(url: imageURL)
        }
    }
}

// MARK: - Private

private extension UserProfileRemoteService {
    
    func userDocument(_ userID: String) -> DocumentReference {
        firestore.collection("users").document(userID)
    }
    
    func createProfile(
        userID: String,
        nickname: String,
        imageData: Data?
    ) async throws {
        let imageURL = try await uploadProfileImage(userID: userID, imageData: imageData)
        
        do {
            try await userDocument(userID).setData([
                "nickname": nickname,
                "profileImageURL": imageURL ?? NSNull(),
                "updatedAt": FieldValue.serverTimestamp()
            ])
        } catch {
            if let imageURL {
                try? await storageService.delete(url: imageURL)
            }
            throw error
        }
    }
    
    func uploadProfileImage(userID: String, imageData: Data?) async throws -> String? {
        guard
            let imageData,
            let resizedData = UIImage(data: imageData)?
                .resizedJPEGData(maxDimension: profileImageMaxDimension)
        else {
            return nil
        }
        
        return try await storageService.upload(
            image: ImageUploadEntity(data: resizedData, fileExtension: "jpg"),
            to: .profile(userId: userID, imageId: UUID().uuidString)
        )
    }
}

// MARK: - Mapping

private extension RemoteUserProfile {
    
    init?(document: DocumentSnapshot) {
        guard let nickname = document.data()?["nickname"] as? String else {
            return nil
        }
        
        self.id = document.documentID
        self.nickname = nickname
        self.profileImageURL = document.data()?["profileImageURL"] as? String
    }
}
