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
        ZStack {
            Color.gray10
                .ignoresSafeArea()
            VStack {
                Spacer().frame(height: 248)
                emptyView
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            store.send(.onAppear)
        }
        .customNavigationBar(
            store: Store(
                initialState: NavigationBarState(
                    title: "알림",
                    leftButton: .back,
                    rightButton: .none,
                    backgroundColor: .gray10
                )
            ) {
                NavigationBarReducer()
            }
        )
    }
}

// MARK: - Subviews

private extension AlarmView {
    var emptyView: some View {
        VStack(spacing: 8) {
            Image("icon_no_alarm")
            Text("아직 알림이 없어요")
                .typography(.body3R)
                .foregroundStyle(.gray60)
        }
        .frame(maxWidth: .infinity)
    }
}
