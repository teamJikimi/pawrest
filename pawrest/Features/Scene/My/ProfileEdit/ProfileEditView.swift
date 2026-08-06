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
            .padding(.top, 20)

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
    }
}

// MARK: - Subviews

private extension ProfileEditView {

    // MARK: 유저 프로필 탭
    var userContent: some View {
        VStack(spacing: 24) {
            userProfileImageSection
                .padding(.top, 32)

            editTextField(
                label: "닉네임",
                text: Binding(
                    get: { store.nickname },
                    set: { store.send(.nicknameChanged($0)) }
                )
            )
            .padding(.horizontal, 20)
        }
    }

    // MARK: 펫 프로필 탭
    var petContent: some View {
        VStack(spacing: 12) {
            petProfileImageSection
                .padding(.top, 32)

            VStack(spacing: 12) {
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

    // MARK: 유저 이미지 라벨
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

    // MARK: 펫 이미지 라벨
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
        HStack(spacing: 12) {
            Text(label)
                .typography(.body2M)
                .foregroundStyle(.gray60)
                .frame(width: 44, alignment: .leading)
            TextField("", text: text)
                .typography(.body2R1)
                .foregroundStyle(.gray80)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(12, corners: .allCorners)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.gray10, lineWidth: 1))
    }

    // MARK: 날짜 필드
    func editDateField(label: String, text: String, onTap: @escaping () -> Void) -> some View {
        HStack(spacing: 12) {
            Text(label)
                .typography(.body2M)
                .foregroundStyle(.gray60)
                .frame(width: 44, alignment: .leading)
            Text(text.isEmpty ? "날짜를 선택하세요" : text)
                .typography(.body2R1)
                .foregroundStyle(text.isEmpty ? .gray40 : .gray80)
            Spacer()
            Image(.imageGrayCalendar)
                .resizable()
                .frame(width: 16, height: 16)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(12, corners: .allCorners)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.gray10, lineWidth: 1))
        .onTapGesture { onTap() }
    }

    // MARK: 저장 버튼
    var saveButton: some View {
        Button {
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
                .background(.pawPrimary)
                .cornerRadius(14, corners: .allCorners)
        }
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
