//
//  RiskLevel.swift
//  pawrest
//
//  Created by 소은 on 5/31/26.
//

import SwiftUI

enum RiskLevel: CaseIterable {
    case stable
    case caution
    case danger
    case highRisk
    
    
    /// PBQ: 0~27 안정 / 28~36 주의 / 37~44 위험 / 45~ 고위험
    static func fromPBQ(score: Int) -> RiskLevel {
        switch score {
        case ..<28: return .stable
        case ..<37: return .caution
        case ..<45: return .danger
        default:    return .highRisk
        }
    }
    
    /// CES-D: 0~15 안정 / 16~20 주의 / 21~40 위험 / 41~ 고위험
    static func fromCESD(score: Int) -> RiskLevel {
        switch score {
        case ..<16: return .stable
        case ..<21: return .caution
        case ..<41: return .danger
        default:    return .highRisk
        }
    }
    
    /// PDS: 0~10 안정 / 11~20 주의 / 21~35 위험 / 36~ 고위험
    static func fromPDS(score: Int) -> RiskLevel {
        switch score {
        case ..<11: return .stable
        case ..<21: return .caution
        case ..<36: return .danger
        default:    return .highRisk
        }
    }
    
    //MARK: Display
    
    var label: String {
        switch self {
        case .stable: return "안정"
        case .caution: return "주의"
        case .danger: return "위험"
        case .highRisk: return "고위험"
        }
    }
    
    var color: Color {
        switch self {
        case .stable: return Color(.pawPrimary)
        case .caution: return Color(.pawWarning)
        case .danger: return Color(.accent)
        case .highRisk: return Color(.danger)
        }
    }
}
