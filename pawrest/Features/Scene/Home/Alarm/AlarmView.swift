//
//  AlarmView.swift
//  pawrest
//
//  Created by 소은 on 6/12/26.
//


import SwiftUI
import ComposableArchitecture

struct AlarmView: View {
    let store: StoreOf<AlarmFeature>

    var body: some View {
        VStack {
            Spacer()
            Text("아직 알림이 없어요")
                .typography(.title2)
                .foregroundStyle(.gray50)
            Spacer()
        }
        .onAppear {
            store.send(.onAppear)
        }
        .customNavigationBar(
            store: Store(
                initialState: NavigationBarState(
                    title: "알림",
                    leftButton: .back,
                    rightButton: .none
                )
            ) {
                NavigationBarReducer()
            }
        )
    }
}

