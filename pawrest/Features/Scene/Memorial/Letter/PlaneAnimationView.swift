//
//  PlaneAnimationView.swift
//  pawrest
//
//  Created by 소은 on 5/17/26.
//

import SwiftUI
import Lottie

struct PlaneAnimationView: UIViewRepresentable {
    let shouldAnimate: Bool
    var idleStartFrame: AnimationFrameTime = 0

    class Coordinator {
        var hasStarted = false
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        container.isUserInteractionEnabled = false
        container.clipsToBounds = false
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard !context.coordinator.hasStarted else { return }
        context.coordinator.hasStarted = true

        if shouldAnimate {
            let introView = LottieAnimationView()
            introView.isUserInteractionEnabled = false
            introView.contentMode = .scaleAspectFit
            introView.backgroundColor = .clear
            introView.translatesAutoresizingMaskIntoConstraints = false
            uiView.addSubview(introView)
            NSLayoutConstraint.activate([
                introView.leadingAnchor.constraint(equalTo: uiView.leadingAnchor),
                introView.trailingAnchor.constraint(equalTo: uiView.trailingAnchor),
                introView.topAnchor.constraint(equalTo: uiView.topAnchor),
                introView.bottomAnchor.constraint(equalTo: uiView.bottomAnchor)
            ])
            introView.animation = LottieAnimation.named("paper_plane_curve_intro")
            introView.setValueProvider(
                FloatValueProvider(0),
                keypath: AnimationKeypath(keypath: "sparkle.Transform.Opacity")
            )
            introView.loopMode = .playOnce
            introView.play { finished in
                guard finished else { return }
                Task {
                    if let dotLottie = try? await DotLottieFile.named("paper_plane_idle") {
                        await MainActor.run {
                            let idleView = LottieAnimationView()
                            idleView.isUserInteractionEnabled = false
                            idleView.backgroundColor = .clear
                            idleView.frame = CGRect(x: 26, y: -20, width: 160, height: 160)
                            uiView.addSubview(idleView)
                            idleView.loadAnimation(from: dotLottie)
                            idleView.loopMode = .loop
                            idleView.currentFrame = 0
                            idleView.play()
                            introView.removeFromSuperview() // idle 추가 후 제거
                        }
                    }
                }
            }
        } else {
            addIdleView(to: uiView, startFrame: idleStartFrame)
        }
    }

    private func addIdleView(to container: UIView, startFrame: AnimationFrameTime) {
        Task {
            if let dotLottie = try? await DotLottieFile.named("paper_plane_idle") {
                await MainActor.run {
                    let idleView = LottieAnimationView()
                    idleView.isUserInteractionEnabled = false
                    idleView.backgroundColor = .clear
                    idleView.frame = CGRect(x: 26, y: -20, width: 160, height: 160)
                    container.addSubview(idleView)
                    idleView.loadAnimation(from: dotLottie)
                    idleView.loopMode = .loop
                    idleView.currentFrame = startFrame
                    idleView.play()
                }
            }
        }
    }
}
