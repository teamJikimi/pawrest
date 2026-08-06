//
//  ProfileEditFeature.swift
//  pawrest
//
//  Created by 소은 on 8/6/26.
//

import SwiftUI
import ComposableArchitecture

enum ProfileEditTab: String, CaseIterable, SegmentItem {
    case user = "유저 프로필"
    case pet = "펫 프로필"
    var title: String { rawValue }
}

// MARK: - State

@ObservableState
struct ProfileEditState: Equatable {
    var navigationBar = NavigationBarState(title: "프로필 수정", leftButton: .back, rightButton: .none)
    var selectedTab: ProfileEditTab = .user

    var nickname: String = ""
    var userProfileImage: Data? = nil

    var petName: String = ""
    var petProfileImage: Data? = nil
    var birthday: Date? = nil
    var deathDay: Date? = nil
    var showBirthdayPicker: Bool = false
    var showDeathDayPicker: Bool = false

    var birthdayText: String {
        guard let date = birthday else { return "" }
        let f = DateFormatter(); f.dateFormat = "yyyy.MM.dd"
        return f.string(from: date)
    }

    var deathDayText: String {
        guard let date = deathDay else { return "" }
        let f = DateFormatter(); f.dateFormat = "yyyy.MM.dd"
        return f.string(from: date)
    }
}

// MARK: - Action

@CasePathable
enum ProfileEditAction: Equatable {
    case navigationBar(NavigationBarAction)
    case tabChanged(ProfileEditTab)
    case loaded(nickname: String, userImage: Data?, petName: String, petImage: Data?, birthday: Date?, deathDay: Date?)
    case nicknameChanged(String)
    case userImageSelected(Data?)
    case petNameChanged(String)
    case petImageSelected(Data?)
    case birthdayFieldTapped
    case deathDayFieldTapped
    case birthdaySelected(Date)
    case deathDaySelected(Date)
    case pickerDismissed
    case saveTapped
}

// MARK: - Reducer

struct ProfileEditFeature: Reducer {
    var body: some Reducer<ProfileEditState, ProfileEditAction> {
        Scope(state: \.navigationBar, action: \.navigationBar) {
            NavigationBarReducer()
        }
        Reduce { state, action in
            switch action {
            case .navigationBar:
                return .none
            case .tabChanged(let tab):
                state.selectedTab = tab
                return .none
            case let .loaded(nickname, userImage, petName, petImage, birthday, deathDay):
                state.nickname = nickname
                state.userProfileImage = userImage
                state.petName = petName
                state.petProfileImage = petImage
                state.birthday = birthday
                state.deathDay = deathDay
                return .none
            case .nicknameChanged(let value):
                state.nickname = value
                return .none
            case .userImageSelected(let data):
                state.userProfileImage = data
                return .none
            case .petNameChanged(let value):
                state.petName = value
                return .none
            case .petImageSelected(let data):
                state.petProfileImage = data
                return .none
            case .birthdayFieldTapped:
                state.showBirthdayPicker = true
                return .none
            case .deathDayFieldTapped:
                state.showDeathDayPicker = true
                return .none
            case .birthdaySelected(let date):
                state.birthday = date
                return .none
            case .deathDaySelected(let date):
                state.deathDay = date
                return .none
            case .pickerDismissed:
                state.showBirthdayPicker = false
                state.showDeathDayPicker = false
                return .none
            case .saveTapped:
                return .none
            }
        }
    }
}
