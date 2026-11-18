//
//  BounceButtonStyle.swift
//  pawrest
//
//  Created by 소은 on 11/18/26.
//

import SwiftUI

struct BounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.3), value: configuration.isPressed)
    }
}
