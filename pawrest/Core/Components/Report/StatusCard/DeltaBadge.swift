//
//  DeltaBadge.swift
//  pawrest
//
//  Created by 소은 on 5/31/26.
//

import SwiftUI

public struct DeltaBadge: View {
    let delta: Int
    
    private var icon: Image {
        switch delta {
        case ..<0: return Image(.iconDownArrow)
        case 1...: return Image(.iconUpArrow)
        default:   return Image(systemName: "minus")
        }
    }
    
    private var displayColor: Color {
        switch delta {
        case ..<0: return .pawPrimary
        case 1...: return .danger
        default:   return .gray50
        }
    }
    
    private var displayBackground: Color {
        switch delta {
        case ..<0: return .primaryLight
        case 1...: return .dangerLight
        default:   return .gray20
        }
    }
    
    public var body: some View {
        HStack(spacing: 3) {
            icon
                .resizable()
                .scaledToFit()
                .frame(width: 12, height: 8)
            
            Text(delta == 0 ? "0점" : "\(abs(delta))점")
                .typography(.date)
                .lineLimit(1)
        }
        .foregroundStyle(displayColor)
        .fixedSize()
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(displayBackground)
        .clipShape(Capsule())
    }
}
