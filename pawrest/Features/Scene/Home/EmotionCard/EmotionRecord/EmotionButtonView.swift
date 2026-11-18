//
//  EmotionButtonView.swift
//  pawrest
//
//  Created by 소은 on 6/12/26.
//

import SwiftUI

struct EmotionButtonView: View {
    let emotion: EmotionType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button { action() } label: {
            VStack(spacing: 6) {
                Image(emotion.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)

                Text(emotion.label)
                    .typography(.body3R)
                    .foregroundStyle(.gray80)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.gray0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.pawPrimary : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(BounceButtonStyle())
        .animation(.easeInOut(duration: 0.25), value: isSelected)
    }
}
