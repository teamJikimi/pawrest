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
        VStack(spacing: 0) {
            headerSection
                .padding(.top, 35)
            
            Color.clear.frame(height: 45)
            
            profileImageSection
            
            Color.clear.frame(height: 40)
            
            nameSection
            
            Color.clear.frame(height: 40)
            
            dateSection
            
            Spacer()
            
            nextButton
        }
        .padding(.horizontal, 20)
        .customNavigationBar(
            store: store.scope(state: \.navigationBar, action: \.navigationBar)
        )
        
        //스데 임시 연결
        .navigationDestination(
            isPresented: Binding(
                get: { store.isIntroducePresented },
                set: { if !$0 { store.send(.introduceDismissed) } }
            )
        ) {
            OnboardingIntroduceView(
                store: Store(
                    initialState: OnboardingIntroduceState(
                        nickname: store.nickname,
                        petName: store.petName,
                        userProfileImage: store.userProfileImage,
                        petProfileImage: store.profileImage,
                        petBirthday: store.birthday,
                        petDeathDay: store.deathDay
                    ),
                    reducer: { OnboardingIntroduceReducer() }
                )
            )
        }
        
        .sheet(isPresented: Binding(
            get: { store.showBirthdayPicker },
            set: { if !$0 { store.send(.pickerDismissed) } }
        )) {
            datePickerSheet(
                selection: $tempBirthday,
                onConfirm: {
                    store.send(.birthdaySelected(tempBirthday))
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
            
            OnboardingPagination(totalSteps: 2, currentStep: 1)
                .padding(.top, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var profileImageSection: some View {
        PhotosPicker(
            selection: $selectedItem,
            matching: .images
        ) {
            ZStack(alignment: .center) {
                if let data = store.profileImage,
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 86, height: 86)
                        .clipShape(Circle())
                } else {
                    Image(.profileLarge)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 86, height: 86)
                }
            }
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
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
                .foregroundColor(.gray0)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(store.isNextEnabled ? .pawPrimary : .gray40)
                .cornerRadius(14, corners: .allCorners)
        }
        .disabled(!store.isNextEnabled)
    }
    
    func datePickerSheet(selection: Binding<Date>, onConfirm: @escaping () -> Void) -> some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("확인") { onConfirm() }
                    .typography(.body1M)
                    .foregroundColor(.pawPrimary)
                    .padding(16)
            }
            
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
}
