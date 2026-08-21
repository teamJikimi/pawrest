//
//  RecommendContentCard.swift
//  pawrest
//
//  Created by 곽예리 on 6/14/26.

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct RecommendedContentCard: View {
    let store: StoreOf<RecommendedContentFeature>

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            headerSection
                .padding(.horizontal, 16)
            contentList
        }
        .padding(.top, 20)
        .padding(.bottom, 21)
        .background(.rowMuted)
        .cornerRadius(20, corners: .allCorners)
        .onAppear {
            store.send(.onAppear)
        }
    }
}

// MARK: - Helper

private extension RecommendedContentCard {
    var headerSection: some View {
        HStack {
            Text("추천 콘텐츠")
                .typography(.body1Accent)
                .foregroundStyle(.gray90)

            Spacer()

            // TODO: 콘텐츠 수가 많아지면 전체 목록 화면으로 이동하는 > 버튼 추가
        }
    }

    var contentList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(store.items) { item in
                    contentRow(item)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    func contentRow(_ item: RecommendedContentItem) -> some View {
        Button {
            store.send(.itemTapped(item.id))
        } label: {
            HStack(spacing: 12) {
                Image(item.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)

                Text(item.title)
                    .typography(.body2M)
                    .lineSpacing(1)
                    .foregroundStyle(.gray80)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(14)
            .frame(width: 180, alignment: .leading)
            .background(.white)
            .cornerRadius(10, corners: .allCorners)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    RecommendedContentCard(
        store: Store(initialState: RecommendedContentFeature.State()) {
            RecommendedContentFeature()
        }
    )
    .padding(.horizontal, 20)
}
