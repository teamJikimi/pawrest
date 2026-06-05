//
//  SettingsRow.swift
//  pawrest
//
//  Created by 소은 on 6/6/26.
//


import SwiftUI

// MARK: - Row Type

enum SettingsRowType {
    case chevron
    case value(String)
    case destructive
}

// MARK: - SettingsRow

struct SettingsRow: View {
    let title: String
    let type: SettingsRowType
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button {
            action?()
        } label: {
            HStack {
                Text(title)
                    .typography(.body2R1)
                    .foregroundStyle(titleColor)
                Spacer()
                trailingView
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var trailingView: some View {
        switch type {
        case .chevron:
            Image(.iconBack)
                .resizable()
                .renderingMode(.template)
                .frame(width: 18, height: 18)
                .scaleEffect(x: -1)
                .foregroundStyle(.gray40)
        case .value(let text):
            Text(text)
                .typography(.body2R1)
                .foregroundStyle(.gray70)
        case .destructive:
            EmptyView()
        }
    }
    
    private var titleColor: Color {
        switch type {
        case .destructive: return .danger
        default: return Color(.gray70)
        }
    }
}
