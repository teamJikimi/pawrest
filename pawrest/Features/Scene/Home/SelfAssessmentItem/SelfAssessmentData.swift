//
//  AssessmentData.swift
//  pawrest
//
//  Created by Moon AYoung on 6/12/26.
//

import Foundation

enum SelfAssessmentData {
    
    static func questions(for type: SelfAssessmentType) -> [SelfAssessmentQuestion] {
        switch type {
        case .pbq: return pbqQuestions
        case .cesD: return cesDQuestions
        case .pds: return pdsQuestions
        }
    }
    
    // MARK: - PBQ
    
    static let pbqQuestions: [SelfAssessmentQuestion] = [
        SelfAssessmentQuestion(id: 1, text: "나는 반려동물을 살리지 못한 수의사에게 화가 난다."),
        SelfAssessmentQuestion(id: 2, text: "나는 반려동물의 죽음이 매우 속상하다."),
        SelfAssessmentQuestion(id: 3, text: "반려동물이 없는 나의 삶은 비어있는 것 같다."),
        SelfAssessmentQuestion(id: 4, text: "나는 반려동물의 죽음에 대한 악몽을 꾸고 있다."),
        SelfAssessmentQuestion(id: 5, text: "나는 반려동물이 없는데 대해 외로움을 느낀다."),
        SelfAssessmentQuestion(id: 6, text: "나는 반려동물에게 뭔가 나쁜 일이 일어나고 있다는 사실을 알았어야만 했다."),
        SelfAssessmentQuestion(id: 7, text: "나는 반려동물이 너무나도 그립다."),
        SelfAssessmentQuestion(id: 8, text: "나는 반려동물을 좀 더 잘 돌보지 못한데 대한 죄책감을 느낀다."),
        SelfAssessmentQuestion(id: 9, text: "나는 반려동물을 살리고자 더 많은 행동을 하지 않았던 것에 낙담하였다."),
        SelfAssessmentQuestion(id: 10, text: "나는 반려동물을 생각하면 눈물이 난다."),
        SelfAssessmentQuestion(id: 11, text: "나는 반려동물의 죽음에 영향을 준 사람들에 대해서 화가 난다."),
        SelfAssessmentQuestion(id: 12, text: "나는 반려동물의 죽음에 대해서 큰 슬픔을 느낀다."),
        SelfAssessmentQuestion(id: 13, text: "나는 도움이 되지 않았던 친구/가족에게 화가 난다."),
        SelfAssessmentQuestion(id: 14, text: "반려동물의 마지막 순간에 대한 기억들이 뇌리에서 떠나지 않는다."),
        SelfAssessmentQuestion(id: 15, text: "나는 반려동물의 상실을 극복하지 못할 것 같다."),
        SelfAssessmentQuestion(id: 16, text: "나는 반려동물을 더 많이 사랑해주었다면 좋았을 것이라고 생각한다.")
    ]
    
    // MARK: - CES-D
    
    static let cesDQuestions: [SelfAssessmentQuestion] = [
        SelfAssessmentQuestion(id: 1, text: "평소에는 아무렇지도 않던 일들이 귀찮게 느껴졌다."),
        SelfAssessmentQuestion(id: 2, text: "먹고 싶지 않았다. 입맛이 없었다."),
        SelfAssessmentQuestion(id: 3, text: "가족이나 친구가 도와주더라도 울적한 기분을 떨쳐버릴 수 없었다."),
        SelfAssessmentQuestion(id: 4, text: "다른 사람들만큼 능력이 있다고 느껴졌다.", isReversed: true),
        SelfAssessmentQuestion(id: 5, text: "무슨 일을 하든 정신을 집중하기가 힘들었다."),
        SelfAssessmentQuestion(id: 6, text: "우울했다."),
        SelfAssessmentQuestion(id: 7, text: "하는 일마다 힘들게 느껴졌다."),
        SelfAssessmentQuestion(id: 8, text: "미래에 대하여 희망적으로 느꼈다.", isReversed: true),
        SelfAssessmentQuestion(id: 9, text: "내 인생은 실패작이라는 생각이 들었다."),
        SelfAssessmentQuestion(id: 10, text: "두려움을 느꼈다."),
        SelfAssessmentQuestion(id: 11, text: "잠을 설쳤다. 잠을 잘 이루지 못했다."),
        SelfAssessmentQuestion(id: 12, text: "행복했다.", isReversed: true),
        SelfAssessmentQuestion(id: 13, text: "평소보다 말을 적게 했다. 말수가 줄었다."),
        SelfAssessmentQuestion(id: 14, text: "세상에 홀로 있는 듯한 외로움을 느꼈다."),
        SelfAssessmentQuestion(id: 15, text: "사람들이 나에게 차갑게 대하는 것 같았다."),
        SelfAssessmentQuestion(id: 16, text: "생활이 즐거웠다.", isReversed: true),
        SelfAssessmentQuestion(id: 17, text: "갑자기 울음이 나왔다."),
        SelfAssessmentQuestion(id: 18, text: "슬픔을 느꼈다."),
        SelfAssessmentQuestion(id: 19, text: "사람들이 나를 싫어하는 것 같았다."),
        SelfAssessmentQuestion(id: 20, text: "도무지 무엇을 시작할 기운이 나지 않았다.")
    ]
    
    // MARK: - PDS
    
    static let pdsQuestions: [SelfAssessmentQuestion] = [
        SelfAssessmentQuestion(id: 1, text: "생각하고 싶지 않은데도, 그 당시의 장면이나 생각이 떠오른다."),
        SelfAssessmentQuestion(id: 2, text: "그 사건에 관한 기분 나쁜 꿈이나 악몽을 꾼다."),
        SelfAssessmentQuestion(id: 3, text: "그 사건을 재경험한다. 마치 그 사건이 지금 일어나고 있는 일처럼 느끼거나 행동한다."),
        SelfAssessmentQuestion(id: 4, text: "그 사건이 생각나면 감정의 동요가 일어난다. (예를 들면, 겁에 질리거나 화나거나 슬프거나 죄책감이 든다)"),
        SelfAssessmentQuestion(id: 5, text: "그 사건을 생각하면 신체적인 반응이 일어난다. (예를 들면, 진땀 나거나 가슴 두근 거린다)"),
        SelfAssessmentQuestion(id: 6, text: "그 사건에 대해 생각하거나 말하거나 느끼지 않으려고 애쓴다."),
        SelfAssessmentQuestion(id: 7, text: "그 사건을 생각나게 하는 활동이나 사람, 장소를 피하려고 한다."),
        SelfAssessmentQuestion(id: 8, text: "그 사건에 관한 중요한 부분이 잘 기억나지 않는다."),
        SelfAssessmentQuestion(id: 9, text: "중요한 일에 참석을 잘 안하거나 흥미가 매우 없어졌다."),
        SelfAssessmentQuestion(id: 10, text: "주위 사람들로부터 거리감이 들거나 동떨어진 느낌이 든다."),
        SelfAssessmentQuestion(id: 11, text: "정서적으로 무감각해졌다. (예를 들면, 울 수 없거나 사랑을 느낄 수 없다)"),
        SelfAssessmentQuestion(id: 12, text: "미래의 계획이나 희망이 실현되지 않을 것 같다. (예를 들면, 직업을 가지지 못할 것 같거나 오래 살지 못할 것 같은 느낌이 든다)"),
        SelfAssessmentQuestion(id: 13, text: "잠들기가 어렵거나 잠이 들어도 잘 깨고 잠을 설친다."),
        SelfAssessmentQuestion(id: 14, text: "신경이 예민하거나 사소한 일에도 쉽게 화가 난다."),
        SelfAssessmentQuestion(id: 15, text: "한가지 일에 집중하기가 어렵다. (예를 들면, 대화를 하다가 대화에서 벗어나거나 연속극을 보는데 줄거리를 따라가기가 어렵거나 책을 읽는데 방금 읽은 내용을 기억하기가 어렵다)"),
        SelfAssessmentQuestion(id: 16, text: "지나치게 경계한다. (예를 들면, 주위에서 누가 보고 있는지 확인하거나 당신 뒤에 문이 있을 때 불안해지거나 등)"),
        SelfAssessmentQuestion(id: 17, text: "사소한 일에도 쉽게 흥분하거나 놀란다. (예를 들면, 누가 당신 뒤에서 걷고 있을 때 깜짝 놀란다)")
    ]
}
