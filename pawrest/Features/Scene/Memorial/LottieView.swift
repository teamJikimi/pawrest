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
    
    init(
        animationName: String,
        loopMode: LottieLoopMode = .loop
    ) {
        self.animationName = animationName
        self.loopMode = loopMode
    }
    
    func makeUIView(context: Context) -> UIView {
        UIView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        let animationView = LottieAnimationView()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        uiView.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: uiView.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: uiView.heightAnchor)
        ])
        
        if let url = Bundle.main.url(forResource: animationName, withExtension: "lottie") {
            DotLottieFile.loadedFrom(url: url) { result in
                switch result {
                case .success(let file):
                    animationView.loadAnimation(from: file)
                    animationView.loopMode = self.loopMode
                    animationView.play()
                case .failure(let error):
                    print("Lottie 로드 실패: \(error)")
                }
            }
        }
    }
}
