//
//  OnboardingPagination.swift
//  pawrest
//
//  Created by Moon AYoung on 7/11/26.
//

import SwiftUI

enum IndicatorStyle {
    case onboarding
    case tutorial
    
    var activeWidth: CGFloat {
        switch self {
        case .onboarding: return 28
        case .tutorial: return 15
        }
    }
    
    var inactiveWidth: CGFloat {
        switch self {
        case .onboarding: return 13
        case .tutorial: return 8
        }
    }
    
    var height: CGFloat { 8 }
    
    var activeRadius: CGFloat {
        switch self {
        case .onboarding: return 3
        case .tutorial: return 4
        }
    }
    
    var inactiveRadius: CGFloat {
        switch self {
        case .onboarding: return 3
        case .tutorial: return 4  // ellipse 8x8 → radius 4 = 원
        }
    }
}

struct OnboardingPagination: View {
    let totalSteps: Int
    let currentStep: Int
    var style: IndicatorStyle = .onboarding
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<totalSteps, id: \.self) { index in
                let isActive = index == currentStep
                RoundedRectangle(cornerRadius: isActive ? style.activeRadius : style.inactiveRadius)
                    .fill(isActive ? Color.pawPrimary : .gray30)
                    .frame(
                        width: isActive ? style.activeWidth : style.inactiveWidth,
                        height: style.height
                    )
            }
        }
    }
}
