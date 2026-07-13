//
//  OnboardingIntroduceFeature.swift
//  pawrest
//
//  Created by Moon AYoung on 7/13/26.
//

import Foundation
import ComposableArchitecture

// MARK: - Page Data

struct TitlePart: Equatable {
    let text: String
    let isHighlighted: Bool
    
    static func normal(_ text: String) -> TitlePart {
        TitlePart(text: text, isHighlighted: false)
    }
    
    static func highlight(_ text: String) -> TitlePart {
        TitlePart(text: text, isHighlighted: true)
    }
}

enum IntroduceButtonStyle: Equatable {
    case single(String)
    case dual
}

struct IntroducePage: Equatable {
    let imageAsset: String
    let titleParts: [TitlePart]
    let subtitle: String?
    let buttonStyle: IntroduceButtonStyle
}

// MARK: - State

@ObservableState
struct OnboardingIntroduceState: Equatable {
    let nickname: String
    let petName: String
    var currentPage: Int = 0
    
    var petNameWithParticle: String {
        //+이와, +와 로직
        guard let lastChar = petName.last,
              let scalar = lastChar.unicodeScalars.first,
              scalar.value >= 0xAC00 && scalar.value <= 0xD7A3
        else { return "\(petName)와" }
        let hasBatchim = (scalar.value - 0xAC00) % 28 != 0
        return hasBatchim ? "\(petName)이와" : "\(petName)와"
    }
    
    var pages: [IntroducePage] {
        [
            IntroducePage(
                imageAsset: "image_introduce_1",
                titleParts: [
                    .normal("준비됐어요,\n"),
                    .highlight(nickname),
                    .normal("님")
                ],
                subtitle: "\(petNameWithParticle) 함께했던\n소중한 시간들을 기억해요.",
                buttonStyle: .single("Pawrest 둘러보기")
            ),
            IntroducePage(
                imageAsset: "image_introduce_2",
                titleParts: [
                    .normal("감정을 "),
                    .highlight("기록"),
                    .normal("하고, AI와 함께 돌아봐요")
                ],
                subtitle: "쌓인 감정이 일주일간의 데이터가 되어,\n내 마음 상태를 한눈에 볼 수 있어요.",
                buttonStyle: .single("다음")
            ),
            IntroducePage(
                imageAsset: "image_introduce_3",
                titleParts: [
                    .normal("언제든 찾아와 "),
                    .highlight("그리움"),
                    .normal("을 전해요")
                ],
                subtitle: "우리 아이만을 위한 공간에서\n하늘로 편지를 보낼 수 있어요.",
                buttonStyle: .dual
            ),
            IntroducePage(
                imageAsset: "image_introduce_4",
                titleParts: [
                    .highlight("소중한 기억, "),
                    .normal("앨범에 담아두세요")
                ],
                subtitle: "함께한 사진과 기록을\n앨범으로 모아 언제든 꺼내볼 수 있어요.",
                buttonStyle: .dual
            ),
            IntroducePage(
                imageAsset: "image_introduce_5",
                titleParts: [
                    .normal("같은 마음의 사람들과 "),
                    .highlight("함께해요")
                ],
                subtitle: "펫로스를 경험한 사람들과\n서로의 이야기를 나눠요.",
                buttonStyle: .dual
            )
        ]
    }
    
    var currentPageData: IntroducePage { pages[currentPage] }
    var totalPages: Int { 5 }
    var isFirstPage: Bool { currentPage == 0 }
    var isLastPage: Bool { currentPage == totalPages - 1 }
    var showPagination: Bool { currentPage > 0 }
}

// MARK: - Action

@CasePathable
enum OnboardingIntroduceAction: Equatable {
    case nextTapped
    case previousTapped
    case finishTapped
}

// MARK: - Reducer

struct OnboardingIntroduceReducer: Reducer {
    var body: some Reducer<OnboardingIntroduceState, OnboardingIntroduceAction> {
        Reduce { state, action in
            switch action {
            case .nextTapped:
                if state.currentPage < state.totalPages - 1 {
                    state.currentPage += 1
                }
                return .none
                
            case .previousTapped:
                if state.currentPage > 0 {
                    state.currentPage -= 1
                }
                return .none
                
            case .finishTapped:
                // 홈 화면 이동
                return .none
            }
        }
    }
}
