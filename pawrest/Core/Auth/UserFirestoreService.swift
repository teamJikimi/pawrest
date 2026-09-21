//
//  UserFirestoreService.swift
//  pawrest
//
//  Created by 소은 on 9/17/26.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

final class UserFirestoreService {
    static let shared = UserFirestoreService()
    private let db = Firestore.firestore()
    private init() {}

    // MARK: - 닉네임 중복 체크
    func isNicknameAvailable(_ nickname: String) async throws -> Bool {
        let snapshot = try await db
            .collection("users")
            .whereField("nickname", isEqualTo: nickname)
            .getDocuments()
        
        guard let uid = Auth.auth().currentUser?.uid else { return snapshot.isEmpty }
        
        // 본인 문서만 있으면 사용 가능
        let others = snapshot.documents.filter { $0.documentID != uid }
        return others.isEmpty
    }

    // MARK: - 유저 프로필 저장
    func saveUserProfile(
        nickname: String,
        profileImageData: Data?
    ) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        var imageURL: String? = nil
        if let data = profileImageData {
            imageURL = try await uploadImage(data: data, path: "users/\(uid)/profile.jpg")
        }

        var userData: [String: Any] = [
            "nickname": nickname,
            "createdAt": Timestamp(date: Date())
        ]
        if let url = imageURL {
            userData["profileImageURL"] = url
        }

        try await db.collection("users").document(uid).setData(userData, merge: true)
    }

    // MARK: - 펫 프로필 저장
    func savePetProfile(
        name: String,
        profileImageData: Data?,
        birthday: Date?,
        deathDay: Date?
    ) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        var imageURL: String? = nil
        if let data = profileImageData {
            imageURL = try await uploadImage(data: data, path: "users/\(uid)/pet_profile.jpg")
        }

        var petData: [String: Any] = ["name": name]
        if let url = imageURL { petData["petImageURL"] = url }
        if let birthday { petData["birthday"] = Timestamp(date: birthday) }
        if let deathDay { petData["deathDay"] = Timestamp(date: deathDay) }

        try await db.collection("users").document(uid)
            .collection("pet").document("profile")
            .setData(petData, merge: true)
    }

    // MARK: - 프로필 업데이트 (닉네임/이미지)
//    func updateUserProfile(
//        nickname: String,
//        profileImageData: Data?
//    ) async throws {
//        guard let uid = Auth.auth().currentUser?.uid else { return }
//
//        var updates: [String: Any] = ["nickname": nickname]
//        if let data = profileImageData {
//            let url = try await uploadImage(data: data, path: "users/\(uid)/profile.jpg")
//            updates["profileImageURL"] = url
//        }
//
//        try await db.collection("users").document(uid).setData(updates, merge: true)
//    }

    // MARK: - 이미지 업로드
    private func uploadImage(data: Data, path: String) async throws -> String {
        let resizedData = UIImage(data: data)?.resizedJPEGData(maxDimension: 512) ?? data
        let ref = Storage.storage().reference().child(path)
        _ = try await ref.putDataAsync(resizedData)
        return try await ref.downloadURL().absoluteString
    }
}
