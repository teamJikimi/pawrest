//
//  RecommendContentFeature.swift
//  pawrest
//
//  Created by 곽예리 on 6/14/26.
//

import ComposableArchitecture
import Foundation

// MARK: - Model

struct RecommendedContentItem: Equatable, Identifiable {
    let id: UUID
    let iconName: String
    let title: String

    init(id: UUID = UUID(), iconName: String, title: String) {
        self.id = id
        self.iconName = iconName
        self.title = title
    }
}

// MARK: - Feature

struct RecommendedContentFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var items: [RecommendedContentItem] = .mock
    }

    @CasePathable
    enum Action: Equatable {
        case onAppear
        case itemTapped(RecommendedContentItem.ID)
    }

    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .onAppear:
            // TODO: 추후 서버에서 콘텐츠 목록을 받아오는 로직으로 교체
            return .none

        case .itemTapped:
            // TODO: 콘텐츠 상세 화면 이동 처리
            return .none
        }
    }
}

// MARK: - Mock

extension [RecommendedContentItem] {
    static let mock: Self = [
        RecommendedContentItem(
            iconName: "icon_recommend_guide",
            title: "펫로스 증후군의\n증상과 대처"
        ),
        RecommendedContentItem(
            iconName: "icon_recommend_expert",
            title: "정신과 전문의가\n드리는 조언"
        )
    ]
}
