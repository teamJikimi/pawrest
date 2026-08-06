//
//  RecommendContentFeature.swift
//  pawrest
//
//  Created by 곽예리 on 6/14/26.
//

import ComposableArchitecture
import Foundation
import SwiftUI

// MARK: - Card Model

struct RecommendedContentItem: Equatable, Identifiable {
    let id: UUID
    let iconName: String
    let title: String
    let detail: RecommendedContentDetail

    init(
        id: UUID = UUID(),
        iconName: String,
        title: String,
        detail: RecommendedContentDetail
    ) {
        self.id = id
        self.iconName = iconName
        self.title = title
        self.detail = detail
    }
}

// MARK: - Detail Content Model

struct RecommendedContentDetail: Equatable {
    let headerImageName: String
    let pageTitle: String
    let introHeadline: String
    let introBody: String
    let sections: [ContentSection]
    let closing: ClosingBlock
}

struct ContentSection: Equatable, Identifiable {
    let id = UUID()
    let icon: String
    let iconColor: Color
    let title: String
    let content: SectionContent
}

enum SectionContent: Equatable {
    case bullets([String])
    case numbered([NumberedItem], boxed: Bool)
}

struct NumberedItem: Equatable, Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let description: String
    let subBullets: [String]

    init(number: Int, title: String, description: String, subBullets: [String] = []) {
        self.number = number
        self.title = title
        self.description = description
        self.subBullets = subBullets
    }
}

enum ClosingBlock: Equatable {
    case highlightBox(headline: String)
    case plainQuote(headline: String, body: String)
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
            return .none

        case .itemTapped:
            return .none
        }
    }
}

// MARK: - Mock

extension [RecommendedContentItem] {
    static let mock: Self = [
        RecommendedContentItem(
            iconName: "icon_recommend_guide",
            title: "펫로스 증후군의\n증상과 대처",
            detail: RecommendedContentDetail(
                headerImageName: "img_recommend_1",
                pageTitle: "펫로스 증후군의 증상과 대처",
                introHeadline: "반려동물을 떠나보낸 마음, 어떻게 다뤄야 할까요?",
                introBody: "반려동물과의 이별 후 찾아오는 슬픔은 사람을 잃은 것과 다르지 않은 깊이를 가집니다. 이를 '펫로스 증후군'이라 부르며, 다음과 같은 반응들이 흔히 나타납니다.",
                sections: [
                    ContentSection(
                        icon: "bolt.fill",
                        iconColor: .accent,
                        title: "주요 증상",
                        content: .bullets([
                            "반복적으로 떠오르는 반려동물과의 기억, 죄책감(\"더 잘해줬어야 했는데\")",
                            "식욕 저하, 수면 장애, 무기력감",
                            "일상에 대한 흥미 상실, 집중력 저하",
                            "반려동물의 흔적(사료 그릇, 장난감 등)을 볼 때마다 밀려오는 슬픔",
                            "주변 사람들이 \"그냥 동물인데\"라고 할 때 느끼는 이해받지 못하는 소외감"
                        ])
                    ),
                    ContentSection(
                        icon: "plus",
                        iconColor: .pawPrimary,
                        title: "건강하게 대처하는 방법",
                        content: .numbered([
                            NumberedItem(
                                number: 1,
                                title: "슬픔을 억누르지 않기",
                                description: "슬퍼하는 것은 자연스러운 애도 과정입니다. 참지 말고 충분히 슬퍼할 시간을 가지세요."
                            ),
                            NumberedItem(
                                number: 2,
                                title: "기록하고 표현하기",
                                description: "일기, 편지, 사진 정리 등으로 감정을 밖으로 꺼내보세요."
                            ),
                            NumberedItem(
                                number: 3,
                                title: "같은 경험을 한 사람들과 연결되기",
                                description: "비슷한 상실을 겪은 사람들과의 대화는 큰 위로가 됩니다."
                            ),
                            NumberedItem(
                                number: 4,
                                title: "일상의 루틴을 서서히 회복하기",
                                description: "무리하지 않는 선에서 규칙적인 생활을 이어가세요."
                            ),
                            NumberedItem(
                                number: 5,
                                title: "2주 이상 일상생활이 어려울 정도로 힘들다면",
                                description: "전문가의 도움을 받는 것을 고려해보세요."
                            )
                        ], boxed: false)
                    )
                ],
                closing: .highlightBox(
                    headline: "펫로스는 '극복해야 할 문제'가 아니라,\n'함께 지나가야 할 애도의 여정'입니다."
                )
            )
        ),
        RecommendedContentItem(
            iconName: "icon_recommend_expert",
            title: "정신과 전문의가\n드리는 조언",
            detail: RecommendedContentDetail(
                headerImageName: "img_recommend_2",
                pageTitle: "정신과 전문의가 드리는 조언",
                introHeadline: "\"괜찮아지려고 애쓰지 않아도 됩니다.\"",
                introBody: "많은 보호자분들이 슬픔이 오래가는 것에 대해 스스로를 자책합니다. 하지만 애도에는 정해진 기간이 없습니다. 반려동물과 함께한 시간이 길고 깊었다면, 그만큼 애도의 시간도 충분히 필요합니다.",
                sections: [
                    ContentSection(
                        icon: "checkmark",
                        iconColor: .pawPrimary,
                        title: "전문가가 강조하는 세 가지",
                        content: .numbered([
                            NumberedItem(
                                number: 1,
                                title: "죄책감과 사실을 구분하세요.",
                                description: "\"내가 더 빨리 알아챘더라면\"이라는 생각은 자연스럽지만, 대부분 사실이 아닌 감정적 해석입니다. 스스로를 탓하는 생각이 반복된다면, 그 생각이 진짜인지 한 번 더 점검해보세요."
                            ),
                            NumberedItem(
                                number: 2,
                                title: "감정에 이름을 붙여보세요.",
                                description: "막연한 슬픔보다 \"지금 나는 그리움을 느끼고 있다\", \"지금은 화가 난다\"처럼 구체적으로 이름을 붙이면 감정을 다루기가 한결 수월해집니다."
                            ),
                            NumberedItem(
                                number: 3,
                                title: "다음 신호가 있다면 전문가와 상담하세요.",
                                description: "",
                                subBullets: [
                                    "2주 이상 일상생활(식사, 수면, 업무)이 어려운 경우",
                                    "죽음이나 자해에 대한 생각이 든 경우",
                                    "감정이 무뎌지고 아무것도 느껴지지 않는 상태가 지속되는 경우"
                                ]
                            )
                        ], boxed: true)
                    )
                ],
                closing: .plainQuote(
                    headline: "\"반려동물을 잃은 슬픔은 작은 슬픔이 아닙니다.\"",
                    body: "그 존재가 내 삶에 남긴 자리만큼, 슬픔도 정직하게 크다는 것을 기억해주세요. 혼자 견디지 않으셔도 됩니다."
                )
            )
        )
    ]
}
