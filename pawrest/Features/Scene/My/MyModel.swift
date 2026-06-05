//
//  MyModel.swift
//  pawrest
//
//  Created by 소은 on 6/6/26.
//


import Foundation

struct MyModel: Equatable {
    var userName: String
    var petName: String
    var petBirthDate: String
    var petDeathDate: String
    var petImageURL: String?
}

// MARK: - Mock

extension MyModel {
    static let mock = MyModel(
        userName: "소은",
        petName: "코코",
        petBirthDate: "2020.03.15",
        petDeathDate: "2024.01.20",
        petImageURL: "profile_large"
    )
}
