//
//  AssessmentModel.swift
//  pawrest
//
//  Created by Moon AYoung on 6/12/26.
//

import Foundation
import SwiftData

// MARK: - SelfAssessment Type

enum SelfAssessmentType: String, CaseIterable, Equatable, Identifiable {
    case pbq
    case cesD
    case pds
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .pbq: return "PBQ 펫로스 심리 척도"
        case .cesD: return "CES-D 우울감 척도"
        case .pds: return "PDS 외상 스트레스 척도"
        }
    }
    
    var listTitle: String {
        switch self {
        case .pbq: return "반려동물 사별 설문 검사(PBQ)"
        case .cesD: return "우울감 척도(CES-D)"
        case .pds: return "PTSD 진단 척도(PDS)"
        }
    }
    
    var description: String {
        switch self {
        case .pbq: return "펫로스로 인한 슬픔, 죄책감, 그리움을 측정하는 검사입니다.\n지금 내가 겪는 감정을 보다 정확하게 이해할 수 있습니다."
        case .cesD: return "지난 일주일간의 감정과 신체 변화를 살펴보는 검사입니다.\n현재 우울 수준을 객관적으로 파악하는 데 도움을 줍니다."
        case .pds: return "펫로스 이후 나타나는 외상 반응을 확인하는 검사입니다.\n일상 속 스트레스 수준을 구체적으로 살펴볼 수 있습니다."
        }
    }
    
    var questionCount: Int {
        SelfAssessmentData.questions(for: self).count
    }
    
    var estimatedTime: String {
        switch self {
        case .pbq: return "약 3~4분"
        case .cesD: return "약 4~5분"
        case .pds: return "약 4~6분"
        }
    }
    
    var instruction: String {
        switch self {
        case .pbq: return "다음은 반려동물을 떠나보낸 후 경험하는 다양한 감정과 생각에 대한 문항입니다. 현재 나의 상태에 가장 가깝다고 생각되는 항목을 선택해 주세요."
        case .cesD: return "아래 문항을 천천히 읽고, 지난 1주 동안 내가 느끼고 행동한 것과 가장 가깝다고 생각되는 항목을 선택해 주세요."
        case .pds: return "아래 문항은 충격적인 사건을 경험한 후 겪을 수 있는 어려움입니다. 그 사건이 언제 일어났든 관계없이, 지난 한 달 동안 얼마나 자주 힘드셨는지 각 항목을 읽고 선택해 주세요."
        }
    }
    
    var disclaimer: String {
        "이 검사는 심리 진단이 아닙니다.\n현재 나의 상태를 스스로 살펴보는 참고 도구이며,\n전문가의 진단을 대체하지 않습니다."
    }
    
    var questionCategory: String? {
        switch self {
        case .pbq: return nil
        case .cesD: return "지난 한 주 동안"
        case .pds: return "지난 한 달 동안"
        }
    }
    
    var options: [SelfAssessmentOption] {
        switch self {
        case .pbq:
            return [
                SelfAssessmentOption(text: "매우 그렇지 않다", score: 0),
                SelfAssessmentOption(text: "그렇지 않다", score: 1),
                SelfAssessmentOption(text: "그렇다", score: 2),
                SelfAssessmentOption(text: "매우 그렇다", score: 3)
            ]
        case .cesD:
            return [
                SelfAssessmentOption(text: "극히 드물게 (1일 이하)", score: 0),
                SelfAssessmentOption(text: "가끔 (1~2일)", score: 1),
                SelfAssessmentOption(text: "자주 (3~4일)", score: 2),
                SelfAssessmentOption(text: "거의 대부분 (5~7일)", score: 3)
            ]
        case .pds:
            return [
                SelfAssessmentOption(text: "없거나 딱 한번", score: 0),
                SelfAssessmentOption(text: "가끔씩 그렇다 (1주에 1회)", score: 1),
                SelfAssessmentOption(text: "자주 그렇다 (1주에 2~4회)", score: 2),
                SelfAssessmentOption(text: "항상 그렇다 (1주에 5회 이상)", score: 3)
            ]
        }
    }
    
    var resultRanges: [SelfAssessmentResultRange] {
        switch self {
        case .pbq:
            return [
                SelfAssessmentResultRange(minScore: 0, maxScore: 27, label: "평균 미만"),
                SelfAssessmentResultRange(minScore: 28, maxScore: 36, label: "평균 이상 (경계)"),
                SelfAssessmentResultRange(minScore: 37, maxScore: nil, label: "상위 30% 펫로스 증후군 (위험)")
            ]
        case .cesD:
            return [
                SelfAssessmentResultRange(minScore: 0, maxScore: 20, label: "정상"),
                SelfAssessmentResultRange(minScore: 21, maxScore: 40, label: "우울 위험군"),
                SelfAssessmentResultRange(minScore: 41, maxScore: nil, label: "우울증 고위험군")
            ]
        case .pds:
            return [
                SelfAssessmentResultRange(minScore: 0, maxScore: 10, label: "경도 수준"),
                SelfAssessmentResultRange(minScore: 11, maxScore: 20, label: "중등도 수준 (경고)"),
                SelfAssessmentResultRange(minScore: 21, maxScore: 35, label: "중등도-중증 수준 (위험)"),
                SelfAssessmentResultRange(minScore: 36, maxScore: nil, label: "중증 수준 (매우 위험)")
            ]
        }
    }
    
    // MARK: - 채점
    
    func calculateScore(answers: [Int?]) -> Int? {
        let questions = SelfAssessmentData.questions(for: self)
        guard answers.count == questions.count,
              answers.allSatisfy({ $0 != nil })
        else { return nil }
        
        var total = 0
        for (index, answer) in answers.enumerated() {
            guard let answer else { return nil }
            if questions[index].isReversed {
                total += (3 - answer)
            } else {
                total += answer
            }
        }
        return total
    }
    
    func resultLabel(for score: Int) -> String {
        for range in resultRanges {
            let max = range.maxScore ?? Int.max
            if score >= range.minScore && score <= max {
                return range.label
            }
        }
        return ""
    }
}

// MARK: - Question

struct SelfAssessmentQuestion: Equatable, Identifiable {
    let id: Int
    let text: String
    let isReversed: Bool
    
    init(id: Int, text: String, isReversed: Bool = false) {
        self.id = id
        self.text = text
        self.isReversed = isReversed
    }
}

// MARK: - Option

struct SelfAssessmentOption: Equatable {
    let text: String
    let score: Int
}

// MARK: - Result Range

struct SelfAssessmentResultRange: Equatable {
    let minScore: Int
    let maxScore: Int?
    let label: String
}

// MARK: - SwiftData Record

@Model
class AssessmentRecord {
    var typeRawValue: String
    var answers: [Int]
    var totalScore: Int
    var date: Date
    
    var type: SelfAssessmentType? {
        SelfAssessmentType(rawValue: typeRawValue)
    }
    
    init(type: SelfAssessmentType, answers: [Int], totalScore: Int, date: Date = Date()) {
        self.typeRawValue = type.rawValue
        self.answers = answers
        self.totalScore = totalScore
        self.date = date
    }
}
