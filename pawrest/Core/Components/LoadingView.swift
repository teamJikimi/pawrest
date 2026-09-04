//
//  LoadingView.swift
//  pawrest
//
//  Created by 소은 on 8/25/26.
//

import SwiftUI
import Lottie

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.gray0
                .ignoresSafeArea()
            LottieView(animationName: "loding", loopMode: .loop)
                .frame(width: 60, height: 60)
                .offset(y: -60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
