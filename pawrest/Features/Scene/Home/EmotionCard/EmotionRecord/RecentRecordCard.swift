//
//  RecentRecordCard.swift
//  pawrest
//
//  Created by 소은 on 6/12/26.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

// MARK: - View

struct RecentRecordCard: View {
    let store: StoreOf<RecentRecordFeature>
    @Environment(\.modelContext) private var modelContext
    @Query private var allRecords: [EmotionRecordModel]
    
    private var filteredRecords: [EmotionRecordModel] {
        allRecords.filter { record in
            Calendar.current.isDate(record.recordedAt, inSameDayAs: store.selectedDate)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerSection
            recordList
        }
        .padding(20)
        .background(.white)
        .cornerRadius(20, corners: .allCorners)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray20, lineWidth: 1)
        )
    }
}

// MARK: - Helper

private extension RecentRecordCard {
    var headerSection: some View {
        HStack {
            Text("최근 기록")
                .typography(.title2)
                .foregroundStyle(.gray90)
            
            Spacer()
        }
    }
    
    var dateNavigator: some View {
        HStack {
            Button {
                store.send(.previousDateTapped)
            } label: {
                Image(.iconBack)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundStyle(hasPreviousDay ? Color.gray80 : Color.gray40)
            }
            .buttonStyle(.plain)
            .disabled(!hasPreviousDay)
            
            Spacer()
            
            Text(store.selectedDate.formatted(.dateTime.month().day().weekday(.abbreviated).locale(Locale(identifier: "ko_KR"))))
                .typography(.body2R1)
                .foregroundStyle(.gray80)
            
            Spacer()
            
            Button {
                store.send(.nextDateTapped)
            } label: {
                Image(.iconBack)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .rotationEffect(.degrees(180))
                    .foregroundStyle(hasNextDay ? Color.gray80 : Color.gray40)
            }
            .buttonStyle(.plain)
            .disabled(!hasNextDay)
        }
        .padding(.vertical, 8)
        .background(.gray0)
        .cornerRadius(10, corners: .allCorners)
    }
    
    var hasPreviousDay: Bool { true }
    
    var hasNextDay: Bool {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: store.selectedDate) ?? store.selectedDate
        return tomorrow <= Date()
    }
    
    var recordList: some View {
        VStack(spacing: 0) {
            dateNavigator
            
            Divider()
                .padding(.horizontal, -20)
            
            if filteredRecords.isEmpty {
                emptyView
            } else {
                ForEach(filteredRecords, id: \.id) { record in
                    recordRow(record)
                }
            }
        }
    }
    
    var emptyView: some View {
        Text("아직 오늘의 감정이 없어요")
            .typography(.body2R1)
            .foregroundStyle(.gray60)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
    }
    
    func recordRow(_ record: EmotionRecordModel) -> some View {
        HStack(alignment: record.memo.isEmpty ? .center : .top, spacing: 12) {
            if let emotion = record.emotionTypeEnum {
                ZStack {
                    Circle()
                        .stroke(.primaryLight , lineWidth: 1)
                        .frame(width: 36, height: 36)
                    Image(emotion.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 32)
                }
            }
            
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(record.recordedAt.formatted(.dateTime.hour().minute()))
                        .typography(.body2R1)
                        .foregroundStyle(.gray80)
                    
                    Spacer()
                    
                    Button {
                        if let target = allRecords.first(where: { $0.id == record.id }) {
                            modelContext.delete(target)
                        }
                    } label: {
                        Image(.iconClose)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(.gray10)
                
                if !record.memo.isEmpty {
                    Text(record.memo)
                        .typography(.body3R)
                        .foregroundStyle(.gray60)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(.gray0)
                }
            }
            .cornerRadius(10, corners: .allCorners)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray20, lineWidth: 1)
            )
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Preview
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: EmotionRecordModel.self, configurations: config)
    
    let record = EmotionRecordModel(
        emotionType: "comfortable",
        memo: "오늘 기분이 좋아요",
        recordedAt: Date()
    )
    container.mainContext.insert(record)
    
    return RecentRecordCard(
        store: Store(initialState: RecentRecordFeature.State()) {
            RecentRecordFeature()
        }
    )
    .padding(20)
    .background(.gray10)
    .modelContainer(container)
}
