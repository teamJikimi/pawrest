//
//  LottieView.swift
//  pawrest
//
//  Created by 소은 on 7/17/26.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let animationName: String
    let loopMode: LottieLoopMode
    var onComplete: (() -> Void)?

    init(
        animationName: String,
        loopMode: LottieLoopMode = .loop,
        onComplete: (() -> Void)? = nil
    ) {
        self.animationName = animationName
        self.loopMode = loopMode
        self.onComplete = onComplete
    }

    func makeUIView(context: Context) -> LottieAnimationView {
        let animationView = LottieAnimationView()
        animationView.contentMode = .scaleAspectFit
        animationView.translatesAutoresizingMaskIntoConstraints = false

        if let url = Bundle.main.url(forResource: animationName, withExtension: "lottie") {
            DotLottieFile.loadedFrom(url: url) { result in
                switch result {
                case .success(let file):
                    animationView.loadAnimation(from: file)
                    animationView.loopMode = loopMode
                    animationView.play { finished in
                        if finished { onComplete?() }
                    }
                case .failure(let error):
                    print("Lottie 로드 실패: \(error)")
                }
            }
        }

        return animationView
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {}
}
