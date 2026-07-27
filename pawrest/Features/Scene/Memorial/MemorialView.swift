//
//  MemorialView.swift
//  pawrest
//
//  Created by 소은 on 5/17/26.
//

import SwiftUI
import SwiftData
import Lottie
import ComposableArchitecture

struct MemorialView: View {
    @Bindable var store: StoreOf<MemorialReducer>
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LetterModel.sentAt) private var letters: [LetterModel]
    @Query private var petProfiles: [PetProfile]

    @State private var selectedLetter: LetterModel? = nil

    private let tabBarContentHeight: CGFloat = 62
    private let deliveryInterval: TimeInterval = 24 * 60 * 60

    private func activeLetters(now: Date) -> [LetterModel] {
        letters.filter { $0.sentAt.addingTimeInterval(deliveryInterval) > now }
    }

    private func airplaneCount(now: Date) -> Int {
        min(activeLetters(now: now).count, 2)
    }

    private func deliveredCount(now: Date) -> Int {
        letters.filter { $0.sentAt.addingTimeInterval(deliveryInterval) <= now }.count
    }

    private func remainingTimeText(now: Date) -> String {
        guard let earliest = activeLetters(now: now).min(by: { $0.sentAt < $1.sentAt }) else { return "" }
        let remaining = earliest.sentAt.addingTimeInterval(deliveryInterval).timeIntervalSince(now)
        guard remaining > 0 else { return "" }
        let hours = Int(remaining) / 3600
        let minutes = (Int(remaining) % 3600) / 60
        return "\(hours)시간 \(minutes)분 후 새로운 편지를 보낼 수 있어요"
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { (context: TimelineViewDefaultContext) in
            let now = context.date
            let isFull = activeLetters(now: now).count >= 2

            GeometryReader { geo in
                ZStack(alignment: .top) {
                    bottomArea(isFull: isFull, now: now)
                    headerView(now: now)
                    airplanes(geo: geo, now: now)
                }
                .background(
                    Image(.memorialBackgroundView)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                )
                .ignoresSafeArea(.keyboard)
            }
        }
        .onAppear {
            if let name = petProfiles.first?.name {
                store.send(.setPetName(name))
            }
        }
        .onChange(of: petProfiles.first?.name) { _, name in
            if let name {
                store.send(.setPetName(name))
            }
        }
        .sheet(isPresented: Binding(
            get: { store.isLetterPresented },
            set: { if !$0 { store.send(.letterDismissed) } }
        )) {
            if let letterStore = store.scope(state: \.letter, action: \.letter) {
                LetterView(store: letterStore)
                    .presentationDetents([.fraction(0.55)])
                    .presentationCornerRadius(20)
                    .presentationDragIndicator(.hidden)
            }
        }
        .sheet(item: $selectedLetter) { letter in
            SentLetterView(letter: letter, deliveryInterval: deliveryInterval)
                .presentationDetents([.fraction(0.55)])
                .presentationCornerRadius(20)
                .presentationDragIndicator(.hidden)
        }
        .onChange(of: store.pendingSave) { _, pending in
            guard let pending else { return }
            let model = LetterModel(petName: pending.petName, content: pending.content)
            modelContext.insert(model)
            try? modelContext.save()
            store.send(.letterSaved)
        }
    }

    // MARK: - Subviews

    private func headerView(now: Date) -> some View {
        VStack(alignment: .leading, spacing: -12) {
            HStack(alignment: .center, spacing: 6) {
                Image(.imageLetterWhite)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                VStack(alignment: .leading, spacing: 2) {
                    Text("하늘로 전달된 편지")
                        .typography(.body2R1)
                        .foregroundStyle(.gray80)
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Text(String(format: "%02d", deliveredCount(now: now)))
                            .typography(.pageTitle)
                            .foregroundStyle(.pawPrimary)
                        Text("통")
                            .typography(.body2R1)
                            .foregroundStyle(.pawPrimary)
                    }
                }
                Spacer()
            }
            .padding(.leading, 20)

            Image(.imageMemorialLineHeart)
                .resizable()
                .scaledToFit()
                .frame(width: 176, height: 20)
                .clipped()
        }
        .padding(.top, 26)
    }

    private func bottomArea(isFull: Bool, now: Date) -> some View {
        VStack(spacing: 0) {
            Spacer()
            HStack(spacing: 0) {
                ZStack {
                    Image(.imagePetNameSignboard)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 99)
                    Text(store.petName)
                        .font(.custom("Ownglyph_PDH-Rg", size: 22))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 9)
                        .offset(y: -18)
                }
                .padding(.leading, 120)
                Spacer()
            }
            .padding(.bottom, 55)

            VStack(spacing: 10) {
                if isFull {
                    Text("두 통의 편지가 모두 하늘로 전달되는 중이에요")
                        .typography(.body2R1)
                        .foregroundStyle(.gray50)
                }
                Button {
                    store.send(.sendLetterButtonTapped)
                } label: {
                    Text(isFull ? remainingTimeText(now: now) : "오늘의 편지 보내기")
                        .typography(.button)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isFull ? Color.gray40 : Color.pawPrimary)
                        .cornerRadius(14, corners: .allCorners)
                }
                .disabled(isFull)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20 + tabBarContentHeight)
        }
    }

    @ViewBuilder
    private func airplanes(geo: GeometryProxy, now: Date) -> some View {
        let active = activeLetters(now: now)
        let count = airplaneCount(now: now)

        if count >= 1 {
            Button {
                selectedLetter = active[0]
            } label: {
                LottieView(animationName: "Flow_9", loopMode: .loop)
                    .frame(width: 160, height: 160)
            }
            .buttonStyle(.plain)
            .position(x: 93.84, y: 214.77)
        }

        if count >= 2 {
            Button {
                selectedLetter = active[1]
            } label: {
                LottieView(animationName: "Flow_9", loopMode: .loop)
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-35))
            }
            .buttonStyle(.plain)
            .position(x: 287, y: 352)
        }
    }
}
