//
//  PrimaryButton.swift
//  pawrest
//
//  Created by 소은 on 8/6/26.
//

import SwiftUI

struct ActiveButton: View {
    let title: String
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .typography(.button)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isEnabled ? .pawPrimary : .gray40)
                .cornerRadius(14, corners: .allCorners)
        }
        .disabled(!isEnabled)
    }
}
