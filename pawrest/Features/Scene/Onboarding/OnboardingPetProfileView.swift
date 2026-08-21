//
//  OnboardingPetProfileView.swift
//  pawrest
//
//  Created by Moon AYoung on 7/13/26.
//

import SwiftUI
import PhotosUI
import ComposableArchitecture

struct OnboardingPetProfileView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<OnboardingPetProfileReducer>
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var tempBirthday: Date = Date()
    @State private var tempDeathDay: Date = Date()

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                        .padding(.top, 19)

                    Color.clear.frame(height: 45)

                    profileImageSection

                    Color.clear.frame(height: 40)

                    nameSection

                    Color.clear.frame(height: 40)

                    dateSection

                    Spacer(minLength: 40)

                    nextButton
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
                .frame(minHeight: geo.size.height)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            dismissKeyboard()
        }
        .customNavigationBar(
            store: store.scope(state: \.navigationBar, action: \.navigationBar)
        )
        .sheet(isPresented: Binding(
            get: { store.showBirthdayPicker },
            set: { if !$0 { store.send(.pickerDismissed) } }
        )) {
            datePickerSheet(
                selection: $tempBirthday,
                onConfirm: {
                    store.send(.birthdaySelected(tempBirthday))
                    store.send(.pickerDismissed)
                },
                onCancel: {
                    store.send(.pickerDismissed)
                }
            )
        }
        .sheet(isPresented: Binding(
            get: { store.showDeathDayPicker },
            set: { if !$0 { store.send(.pickerDismissed) } }
        )) {
            datePickerSheet(
                selection: $tempDeathDay,
                onConfirm: {
                    store.send(.deathDaySelected(tempDeathDay))
                    store.send(.pickerDismissed)
                },
                onCancel: {
                    store.send(.pickerDismissed)
                }
            )
        }
    }
}

// MARK: - Subviews

private extension OnboardingPetProfileView {

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("추억할 아이를\n소개해주세요.")
                .typography(.title4)
                .foregroundColor(.gray90)
                .fixedSize(horizontal: false, vertical: true)

            OnboardingPagination(totalSteps: 2, currentStep: 1)
                .padding(.top, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var profileImageLabel: some View {
        let clipShape = ProfileClipShape(
            profileSize: 86,
            cutoutSize: 24,
            offset: CGPoint(x: 2, y: 2)
        )
        return ZStack(alignment: .bottomTrailing) {
            Group {
                if let data = store.profileImage,
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(.profileOnboarding)
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

    var profileImageSection: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            profileImageLabel
        }
        .onChange(of: selectedItem) { _, newItem in
            Task { @MainActor in
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    store.send(.profileImageSelected(data))
                }
            }
        }
    }

    var nameSection: some View {
        OnboardingTextField(
            placeholder: "이름을 입력하세요",
            text: Binding(
                get: { store.petName },
                set: { store.send(.petNameChanged($0)) }
            ),
            helper: store.nameHelper
        )
    }

    var dateSection: some View {
        VStack(spacing: 8) {
            OnboardingTextField.withCalendar(
                placeholder: "생일을 설정하세요",
                text: .constant(store.birthdayText),
                onTap: { store.send(.birthdayFieldTapped) }
            )

            OnboardingTextField.withCalendar(
                placeholder: "사별일을 설정하세요",
                text: .constant(store.deathDayText),
                helper: .info("지금 바로 설정하지 않아도 괜찮아요\n나중에 언제든 추가할 수 있어요"),
                onTap: { store.send(.deathDayFieldTapped) }
            )
        }
    }

    var nextButton: some View {
        Button {
            store.send(.nextTapped)
        } label: {
            Text("다음")
                .typography(.button)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(store.isNextEnabled ? Color.pawPrimary : Color.gray40)
                .cornerRadius(14, corners: .allCorners)
        }
        .disabled(!store.isNextEnabled)
    }

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

            DatePicker(
                "",
                selection: selection,
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .environment(\.locale, Locale(identifier: "ko_KR"))
        }
        .presentationDetents([.height(300)])
    }

    func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

#Preview {
    NavigationStack {
        OnboardingPetProfileView(
            store: Store(
                initialState: OnboardingPetProfileState(
                    nickname: "테스트유저",
                    userProfileImage: nil
                )
            ) {
                OnboardingPetProfileReducer()
            }
        )
    }
}
