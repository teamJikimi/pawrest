//
//  EmotionCheckInCard.swift
//  pawrest
//
//  Created by 소은 on 6/12/26.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

// MARK: - View

struct EmotionCheckInCard: View {
    let store: StoreOf<EmotionCheckInFeature>
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerSection
            emotionButtons
            if store.selectedEmotion != nil {
                memoSection
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(20)
        .background(backgroundImage)
        .cornerRadius(20, corners: .allCorners)
        .onAppear { store.send(.onAppear) }
    }
}

// MARK: - Helper

private extension EmotionCheckInCard {
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(store.dateText)
                .typography(.date)
                .foregroundStyle(.gray60)
            Text("지금 마음 상태는 어떤가요?")
                .typography(.body1M)
                .foregroundStyle(.gray90)
        }
    }

    var emotionButtons: some View {
        HStack(spacing: 8) {
            ForEach(EmotionType.allCases, id: \.self) { emotion in
                EmotionButtonView(
                    emotion: emotion,
                    isSelected: store.selectedEmotion == emotion
                ) {
                    store.send(.emotionTapped(emotion))
                }
            }
        }
    }

    var memoSection: some View {
        VStack(spacing: 10) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.gray0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.gray20, lineWidth: 1)
                    )
                    .frame(height: 104)

                if store.memoText.isEmpty {
                    Text("현재 상태에 대해 간단히 메모해보세요.")
                        .typography(.body3R)
                        .foregroundStyle(.gray50)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                }

                TextEditor(text: Binding(
                    get: { store.memoText },
                    set: { newValue in
                        store.send(.memoTextChanged(newValue), animation: .none)
                    }
                ))
                .typography(.body3R)
                .foregroundStyle(.gray90)
                .scrollContentBackground(.hidden)
                .background(.clear)
                .frame(height: 88)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            }

            Button {
                guard let emotion = store.selectedEmotion else { return }
                let record = EmotionRecordModel(
                    emotionType: emotion.rawValue,
                    memo: store.memoText
                )
                modelContext.insert(record)
                store.send(.submitTapped)
            } label: {
                Text("마음 상태 저장하기")
                    .typography(.body2Accent)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(.pawPrimary)
                    .cornerRadius(12, corners: .allCorners)
            }
            .buttonStyle(BounceButtonStyle())
        }
    }

    var backgroundImage: some View {
        Image(store.selectedEmotion != nil ? "emotions_background_long" : "emotions_background")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
}
