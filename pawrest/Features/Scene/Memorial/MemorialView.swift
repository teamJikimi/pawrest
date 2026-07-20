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
                HStack(spacing: 0) {
                    ZStack {
                        Image(.imagePetNameSignboard)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 99)
                        Text(store.petName)
                            .font(.custom("Ownglyph_PDH-Rg", size: 22))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .padding(.horizontal, 25)
                            .padding(.vertical, 9)
                            .offset(y: -18)
                    }
                    .padding(.leading, 111)
                    Spacer()
                }
                .padding(.bottom, 79)

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
        }
        .background(
            Image(.memorialBackgroundView)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: Binding(
            get: { store.isLetterPresented },
            set: { if !$0 { store.send(.letter(.delegate(.didClose))) } }
        )) {
            if let letterStore = store.scope(state: \.letter, action: \.letter) {
                LetterView(store: letterStore)
                    .presentationDetents([.fraction(0.55)])
                    .presentationCornerRadius(20)
                    .presentationDragIndicator(.hidden)
            }
        }
    }
}
