//
//  RiskBadge.swift
//  pawrest
//
//  Created by 소은 on 5/31/26.
//
import SwiftUI

public struct RiskBadge: View {
    let level: RiskLevel

    public var body: some View {
        Text(level.label)
            .typography(.date)
            .foregroundStyle(.gray0)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(level.color)
            .clipShape(Capsule())
    }
}
