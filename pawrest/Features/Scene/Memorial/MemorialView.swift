//
//  MemorialView.swift
//  pawrest
//
//  Created by 소은 on 5/17/26.
//

import SwiftUI
import ComposableArchitecture

struct MemorialView: View {
    @Bindable var store: StoreOf<MemorialReducer>
    private let tabBarContentHeight: CGFloat = 62

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()
                Button {
                    store.send(.sendLetterButtonTapped)
                } label: {
                    Text("편지 보내기")
                        .typography(.button)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.pawPrimary)
                        .cornerRadius(14, corners: .allCorners)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20 + tabBarContentHeight)
            }

            if store.isLetterPresented,
               let letterStore = store.scope(state: \.letter, action: \.letter) {
                Color.black.opacity(0.4).ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer().frame(height: 144)
                    LetterView(store: letterStore)
                        .frame(height: 562)
                        .background(.white)
                        .cornerRadius(20, corners: .allCorners)
                        .padding(.horizontal, 20)
                    Spacer()
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .background(
            Image(.memorialBackgroundView)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
        .ignoresSafeArea(.keyboard)
        .animation(.easeInOut(duration: 0.2), value: store.isLetterPresented)
    }
}
