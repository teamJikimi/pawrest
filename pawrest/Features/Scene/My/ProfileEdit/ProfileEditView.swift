//
//  ProfileEditView.swift
//  pawrest
//
//  Created by 소은 on 8/6/26.
//

import SwiftUI
import SwiftData
import PhotosUI
import ComposableArchitecture

struct ProfileEditView: View {
    @Bindable var store: StoreOf<ProfileEditFeature>
    @Query private var userProfiles: [UserProfile]
    @Query private var petProfiles: [PetProfile]
    @Environment(\.modelContext) private var modelContext

    @State private var selectedUserItem: PhotosPickerItem? = nil
    @State private var selectedPetItem: PhotosPickerItem? = nil
    @State private var tempBirthday: Date = Date()
    @State private var tempDeathDay: Date = Date()
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            SegmentTabBar(
                items: ProfileEditTab.allCases,
                selection: Binding(
                    get: { store.selectedTab },
                    set: { store.send(.tabChanged($0)) }
                )
            )
            .padding(.horizontal, 20)
            .padding(.top, 12)

            switch store.selectedTab {
            case .user:
                userContent
            case .pet:
                petContent
            }

            Spacer()

            saveButton
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
        }
        .customNavigationBar(store: store.scope(state: \.navigationBar, action: \.navigationBar))
        .onAppear {
            if let user = userProfiles.first, let pet = petProfiles.first {
                store.send(.loaded(
                    nickname: user.nickname,
                    userImage: user.profileImage,
                    petName: pet.name,
                    petImage: pet.profileImage,
                    birthday: pet.birthday,
                    deathDay: pet.deathDay
                ))
                if let b = pet.birthday { tempBirthday = b }
                if let d = pet.deathDay { tempDeathDay = d }
            }
        }
        .sheet(isPresented: Binding(
            get: { store.showBirthdayPicker },
            set: { if !$0 { store.send(.pickerDismissed) } }
        )) {
            datePickerSheet(selection: $tempBirthday) {
                store.send(.birthdaySelected(tempBirthday))
                store.send(.pickerDismissed)
            } onCancel: {
                store.send(.pickerDismissed)
            }
        }
        .sheet(isPresented: Binding(
            get: { store.showDeathDayPicker },
            set: { if !$0 { store.send(.pickerDismissed) } }
        )) {
            datePickerSheet(selection: $tempDeathDay) {
                store.send(.deathDaySelected(tempDeathDay))
                store.send(.pickerDismissed)
            } onCancel: {
                store.send(.pickerDismissed)
            }
        }
        .hideTabBar()
        .toast(
            isPresented: Binding(
                get: { store.showSavedToast },
                set: { if !$0 { store.send(.toastDismissed) } }
            ),
            message: "프로필이 저장되었어요"
        )
    }
}

// MARK: - Subviews

private extension ProfileEditView {

    // MARK: 유저 프로필 탭
    var userContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            userProfileImageSection
                .padding(.top, 40)
                .frame(maxWidth: .infinity)

            nicknameField
                .padding(.top, 40)

            if let helperText = store.nicknameStatus.helper.text {
                Text(helperText)
                    .typography(.body4R)
                    .foregroundColor(store.nicknameStatus.helper.color)
                    .padding(.top, 10)
                    .padding(.leading, 5)
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: 닉네임 필드
    var nicknameField: some View {
        HStack(spacing: 0) {
            Text("닉네임")
                .typography(.body1M)
                .foregroundStyle(.gray80)
                .frame(width: 44, alignment: .leading)

            Rectangle()
                .fill(Color.gray20)
                .frame(width: 1, height: 18)
                .padding(.leading, 10)
                .padding(.trailing, 10)

            TextField("", text: Binding(
                get: { store.nickname },
                set: { store.send(.nicknameChanged($0)) }
            ))
            .typography(.body1R)
            .foregroundStyle(.gray80)
            .focused($isFocused)

            Button {
                store.send(.duplicateCheckTapped)
            } label: {
                Text("중복체크")
                    .typography(.body3R)
                    .foregroundStyle(.gray0)
                    .padding(.horizontal, 10)
                    .frame(height: 24)
                    .background(store.isDuplicateCheckEnabled ? .pawPrimary : .gray40)
                    .cornerRadius(11, corners: .allCorners)
            }
            .disabled(!store.isDuplicateCheckEnabled)
        }
        .padding(.horizontal, 16)
        .frame(height: 45)
        .background(Color.white)
        .cornerRadius(10, corners: .allCorners)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.gray10, lineWidth: 1))
    }

    // MARK: 펫 프로필 탭
    var petContent: some View {
        VStack(spacing: 40) {
            petProfileImageSection
                .padding(.top, 40)

            VStack(spacing: 8) {
                editTextField(
                    label: "이름",
                    text: Binding(
                        get: { store.petName },
                        set: { store.send(.petNameChanged($0)) }
                    )
                )

                editDateField(
                    label: "생일",
                    text: store.birthdayText,
                    onTap: { store.send(.birthdayFieldTapped) }
                )

                editDateField(
                    label: "사별일",
                    text: store.deathDayText,
                    onTap: { store.send(.deathDayFieldTapped) }
                )
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: 유저 이미지
    var userProfileImageLabel: some View {
        let clipShape = ProfileClipShape(profileSize: 86, cutoutSize: 24, offset: CGPoint(x: 2, y: 2))
        return ZStack(alignment: .bottomTrailing) {
            Group {
                if let data = store.userProfileImage, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(.profileUser)
                        .resizable()
                        .scaledToFit()
                }
            }
            .frame(width: 86, height: 86)
            .clipShape(clipShape)
            .overlay(clipShape.stroke(.gray40, lineWidth: 1))

            Image(.iconImageEdit)
                .resizable()
                .scaledToFit()
                .frame(width: 27, height: 27)
                .offset(x: 3, y: 3)
        }
    }

    var userProfileImageSection: some View {
        PhotosPicker(selection: $selectedUserItem, matching: .images) {
            userProfileImageLabel
        }
        .onChange(of: selectedUserItem) { _, newItem in
            Task { @MainActor in
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    store.send(.userImageSelected(data))
                }
            }
        }
    }

    // MARK: 펫 이미지
    var petProfileImageLabel: some View {
        let clipShape = ProfileClipShape(profileSize: 86, cutoutSize: 24, offset: CGPoint(x: 2, y: 2))
        return ZStack(alignment: .bottomTrailing) {
            Group {
                if let data = store.petProfileImage, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(.profileLarge)
                        .resizable()
                        .scaledToFit()
                }
            }
            .frame(width: 86, height: 86)
            .clipShape(clipShape)
            .overlay(clipShape.stroke(.gray40, lineWidth: 1))

            Image(.iconImageEdit)
                .resizable()
                .scaledToFit()
                .frame(width: 27, height: 27)
                .offset(x: 3, y: 3)
        }
    }

    var petProfileImageSection: some View {
        PhotosPicker(selection: $selectedPetItem, matching: .images) {
            petProfileImageLabel
        }
        .onChange(of: selectedPetItem) { _, newItem in
            Task { @MainActor in
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    store.send(.petImageSelected(data))
                }
            }
        }
    }

    // MARK: 텍스트 필드
    func editTextField(label: String, text: Binding<String>) -> some View {
        HStack(spacing: 0) {
            Text(label)
                .typography(.body1M)
                .foregroundStyle(.gray80)
                .frame(width: 44, alignment: .leading)

            Rectangle()
                .fill(Color.gray20)
                .frame(width: 1, height: 18)
                .padding(.leading, 10)
                .padding(.trailing, 10)

            TextField("", text: text)
                .typography(.body1R)
                .foregroundStyle(.gray80)
                .focused($isFocused)
        }
        .padding(.horizontal, 16)
        .frame(height: 45)
        .background(Color.white)
        .cornerRadius(10, corners: .allCorners)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.gray10, lineWidth: 1))
    }

    // MARK: 날짜 필드
    func editDateField(label: String, text: String, onTap: @escaping () -> Void) -> some View {
        HStack(spacing: 0) {
            Text(label)
                .typography(.body1M)
                .foregroundStyle(.gray80)
                .frame(width: 44, alignment: .leading)

            Rectangle()
                .fill(Color.gray20)
                .frame(width: 1, height: 18)
                .padding(.leading, 10)
                .padding(.trailing, 10)

            Text(text.isEmpty ? "날짜를 선택하세요" : text)
                .typography(.body1R)
                .foregroundStyle(text.isEmpty ? .gray40 : .gray80)

            Spacer()

            Image(.iconCalender)
                .resizable()
                .frame(width: 24, height: 24)
        }
        .padding(.horizontal, 16)
        .frame(height: 45)
        .background(Color.white)
        .cornerRadius(10, corners: .allCorners)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.gray10, lineWidth: 1))
        .onTapGesture { onTap() }
    }

    // MARK: 저장 버튼
    var saveButton: some View {
        Button {
            isFocused = false
            store.send(.saveTapped)
            if let user = userProfiles.first {
                user.nickname = store.nickname
                user.profileImage = store.userProfileImage
            }
            if let pet = petProfiles.first {
                pet.name = store.petName
                pet.profileImage = store.petProfileImage
                pet.birthday = store.birthday
                pet.deathDay = store.deathDay
            }
            try? modelContext.save()
        } label: {
            Text("저장")
                .typography(.button)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(store.isChanged ? .pawPrimary : .gray40)
                .cornerRadius(14, corners: .allCorners)
        }
        .disabled(!store.isChanged)
    }

    // MARK: 날짜 피커 시트
    func datePickerSheet(selection: Binding<Date>, onConfirm: @escaping () -> Void, onCancel: @escaping () -> Void) -> some View {
        VStack(spacing: 0) {
            HStack {
                Button("취소") { onCancel() }
                    .typography(.body1M)
                    .foregroundColor(.gray70)
                Spacer()
                Button("확인") { onConfirm() }
                    .typography(.body1M)
                    .foregroundColor(.pawPrimary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            DatePicker("", selection: selection, in: ...Date(), displayedComponents: .date)
                .datePickerStyle(.wheel)
                .labelsHidden()
                .environment(\.locale, Locale(identifier: "ko_KR"))
        }
        .presentationDetents([.height(300)])
    }
}
