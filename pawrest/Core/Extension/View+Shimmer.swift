//
//  View+Shimmer.swift
//  pawrest
//
//  Created by 소은 on 8/18/26.
//

import SwiftUI

struct ShimmerModifier: ViewModifier {
    @State private var isAnimating = false

    func body(content: Content) -> some View {
        content
            .opacity(isAnimating ? 0.35 : 0.75)
            .animation(
                .easeInOut(duration: 0.85).repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear { isAnimating = true }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}
