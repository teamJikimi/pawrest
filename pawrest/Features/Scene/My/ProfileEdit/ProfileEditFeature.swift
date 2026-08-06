//
//  ProfileEditFeature.swift
//  pawrest
//

import Foundation
import ComposableArchitecture

// MARK: - Tab

enum ProfileEditTab: String, CaseIterable, Equatable, SegmentItem {
    case user = "유저 프로필"
    case pet = "펫 프로필"

    var title: String { rawValue }
}

// MARK: - State

@ObservableState
struct ProfileEditState: Equatable {
    var navigationBar = NavigationBarState(title: "프로필 수정", leftButton: .back, rightButton: .none)
    var selectedTab: ProfileEditTab = .user

    // 유저
    var nickname: String = ""
    var userProfileImage: Data? = nil
    var nicknameStatus: NicknameStatus = .idle

    // 펫
    var petName: String = ""
    var petProfileImage: Data? = nil
    var birthday: Date? = nil
    var deathDay: Date? = nil
    var showBirthdayPicker: Bool = false
    var showDeathDayPicker: Bool = false

    // 토스트
    var showSavedToast: Bool = false

    // 원본값
    var originalNickname: String = ""
    var originalUserProfileImage: Data? = nil
    var originalPetName: String = ""
    var originalPetProfileImage: Data? = nil
    var originalBirthday: Date? = nil
    var originalDeathDay: Date? = nil

    var isFormatValid: Bool {
        let trimmed = nickname
        guard trimmed.count >= 2 && trimmed.count <= 12 else { return false }
        let pattern = "^[가-힣a-zA-Z0-9]+$"
        return trimmed.range(of: pattern, options: .regularExpression) != nil
    }

    var isDuplicateCheckEnabled: Bool {
        isFormatValid && nicknameStatus != .checking && nicknameStatus != .available
    }

    var isChanged: Bool {
        nickname != originalNickname ||
        userProfileImage != originalUserProfileImage ||
        petName != originalPetName ||
        petProfileImage != originalPetProfileImage ||
        birthday != originalBirthday ||
        deathDay != originalDeathDay
    }

    var birthdayText: String {
        guard let date = birthday else { return "" }
        let f = DateFormatter()
        f.dateFormat = "yyyy.MM.dd"
        return f.string(from: date)
    }

    var deathDayText: String {
        guard let date = deathDay else { return "" }
        let f = DateFormatter()
        f.dateFormat = "yyyy.MM.dd"
        return f.string(from: date)
    }
}

// MARK: - Action

@CasePathable
enum ProfileEditAction: Equatable {
    case navigationBar(NavigationBarAction)
    case tabChanged(ProfileEditTab)
    case loaded(nickname: String, userImage: Data?, petName: String, petImage: Data?, birthday: Date?, deathDay: Date?)

    // 유저
    case nicknameChanged(String)
    case userImageSelected(Data?)
    case duplicateCheckTapped
    case duplicateCheckResult(isAvailable: Bool)

    // 펫
    case petNameChanged(String)
    case petImageSelected(Data?)
    case birthdayFieldTapped
    case deathDayFieldTapped
    case birthdaySelected(Date)
    case deathDaySelected(Date)
    case pickerDismissed

    // 저장
    case saveTapped
    case toastDismissed
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
                state.originalNickname = nickname
                state.originalUserProfileImage = userImage
                state.originalPetName = petName
                state.originalPetProfileImage = petImage
                state.originalBirthday = birthday
                state.originalDeathDay = deathDay
                return .none

            case .nicknameChanged(let raw):
                let filtered = raw.filter { char in
                    let s = String(char)
                    return s.range(of: "^[가-힣ㄱ-ㅎㅏ-ㅣa-zA-Z0-9]$", options: .regularExpression) != nil
                }
                state.nickname = String(filtered.prefix(12))
                if state.nicknameStatus == .available || state.nicknameStatus == .duplicated {
                    state.nicknameStatus = .idle
                }
                return .none

            case .userImageSelected(let data):
                state.userProfileImage = data
                return .none

            case .duplicateCheckTapped:
                guard state.isFormatValid else {
                    state.nicknameStatus = .formatError
                    return .none
                }
                state.nicknameStatus = .checking
                return .run { send in
                    try await Task.sleep(for: .milliseconds(500))
                    await send(.duplicateCheckResult(isAvailable: true))
                }

            case .duplicateCheckResult(let isAvailable):
                state.nicknameStatus = isAvailable ? .available : .duplicated
                return .none

            case .petNameChanged(let name):
                state.petName = name
                return .none

            case .petImageSelected(let data):
                state.petProfileImage = data
                return .none

            case .birthdayFieldTapped:
                state.showBirthdayPicker = true
                state.showDeathDayPicker = false
                return .none

            case .deathDayFieldTapped:
                state.showDeathDayPicker = true
                state.showBirthdayPicker = false
                return .none

            case .birthdaySelected(let date):
                state.birthday = date
                state.showBirthdayPicker = false
                return .none

            case .deathDaySelected(let date):
                state.deathDay = date
                state.showDeathDayPicker = false
                return .none

            case .pickerDismissed:
                state.showBirthdayPicker = false
                state.showDeathDayPicker = false
                return .none

            case .saveTapped:
                state.showSavedToast = true
                state.originalNickname = state.nickname
                state.originalUserProfileImage = state.userProfileImage
                state.originalPetName = state.petName
                state.originalPetProfileImage = state.petProfileImage
                state.originalBirthday = state.birthday
                state.originalDeathDay = state.deathDay
                return .none

            case .toastDismissed:
                state.showSavedToast = false
                return .none
            }
        }
    }
}
