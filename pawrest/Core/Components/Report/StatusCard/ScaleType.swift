//
//  ScaleType.swift
//  pawrest
//
//  Created by 소은 on 5/31/26.
//

import SwiftUI

enum ScaleType {
    case pbq
    case cesd
    case pds

    func riskLevel(for score: Int) -> RiskLevel {
        switch self {
        case .pbq:  return .fromPBQ(score: score)
        case .cesd: return .fromCESD(score: score)
        case .pds:  return .fromPDS(score: score)
        }
    }

    var maxScore: Int {
        switch self {
        case .pbq:  return 60
        case .cesd: return 60
        case .pds:  return 51
        }
    }
}
