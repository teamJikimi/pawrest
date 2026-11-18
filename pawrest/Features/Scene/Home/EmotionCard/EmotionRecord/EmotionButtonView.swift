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

    @State private var isPressed = false

    var body: some View {
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
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.3), value: isPressed)
        .onTapGesture {
            isPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                isPressed = false
            }
            action()
        }
        .animation(.easeInOut(duration: 0.25), value: isSelected)
    }
}
