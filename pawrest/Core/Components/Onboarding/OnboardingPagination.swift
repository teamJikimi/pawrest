//
//  OnboardingPagination.swift
//  pawrest
//
//  Created by Moon AYoung on 7/11/26.
//

import SwiftUI

enum IndicatorStyle {
    case onboarding
    case introduce
    
    var activeWidth: CGFloat {
        switch self {
        case .onboarding: return 28
        case .introduce: return 15
        }
    }
    
    var inactiveWidth: CGFloat {
        switch self {
        case .onboarding: return 13
        case .introduce: return 8
        }
    }
    
    var height: CGFloat { 8 }
    
    var activeRadius: CGFloat {
        switch self {
        case .onboarding: return 3
        case .introduce: return 4
        }
    }
    
    var inactiveRadius: CGFloat {
        switch self {
        case .onboarding: return 3
        case .introduce: return 4
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
                    .fill(color(for: index))
                    .frame(
                        width: isActive ? style.activeWidth : style.inactiveWidth,
                        height: style.height
                    )
            }
        }
    }

    private func color(for index: Int) -> Color {
        if index == currentStep {
            return .pawPrimary
        } else if index < currentStep {
            return .primaryLight
        } else {
            return .gray30
        }
    }
}
