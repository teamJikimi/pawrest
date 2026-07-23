
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
        .animation(.none, value: store.selectedEmotion)
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
                emotionButton(emotion)
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
                .frame(height: 104)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            }
            
            Button {
                guard let emotion = store.selectedEmotion else { return }
                let memo = store.memoText
                let record = EmotionRecordModel(
                    emotionType: emotion.rawValue,
                    memo: memo
                )
                modelContext.insert(record)
                store.send(.submitTapped)
            } label: {
                Text("마음 상태 저장하기")
                    .typography(.body2Accent)
                    .foregroundStyle(.gray0)
                    .frame(maxWidth: .infinity)
                    .frame(height: 32)
                    .background(.pawPrimary)
                    .cornerRadius(24, corners: .allCorners)
            }
        }
    }
    
    var backgroundImage: some View {
        Image(store.selectedEmotion != nil ? "emotions_background_long" : "emotions_background")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
    
    func emotionButton(_ emotion: EmotionType) -> some View {
        Button {
                store.send(.emotionTapped(emotion))
        } label: {
            VStack(spacing: 6) {
                Image(emotion.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                
                Text(emotion.label)
                    .typography(.body3R)
                    .foregroundStyle(.gray80)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.gray0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(store.selectedEmotion == emotion ? .pawPrimary : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.25), value: store.selectedEmotion)
    }
}
