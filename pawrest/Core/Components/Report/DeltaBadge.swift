//
//  DeltaBadge.swift
//  pawrest
//
//  Created by 소은 on 5/31/26.
//

import SwiftUI

public struct DeltaBadge: View {
    let delta: Int

    private var icon: String {
        switch delta {
        case ..<0: return "arrowtriangle.down.fill"
        case 1...: return "arrowtriangle.up.fill"
        default:   return "minus"
        }
    }

    private var displayColor: Color {
        switch delta {
        case ..<0: return Color(.pawPrimary)
        case 1...: return Color(.danger)
        default:   return Color(.gray30)
        }
    }

    private var displayBackground: Color {
        displayColor.opacity(0.15)
    }

    public var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(delta == 0 ? "0점" : "\(abs(delta))점")
                .typography(.date)
        }
        .foregroundStyle(displayColor)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(displayBackground)
        .clipShape(Capsule())
    }
}
