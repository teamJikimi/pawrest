//
//  BlockedListView.swift
//  pawrest
//
//  Created by 소은 on 6/6/26.
//

import SwiftUI
import ComposableArchitecture

struct BlockedListView: View {
    @Bindable var store: StoreOf<BlockedListFeature>
   
    // MARK: - View
    var body: some View {
        ZStack {
            ScrollView {
                // 추후 구현
            }
            
            Text("차단한 사용자가 없어요")
                .typography(.body1R)
                .foregroundStyle(.gray60)
        }
        .background(.gray0)
        .customNavigationBar(store: store.scope(state: \.navigationBar, action: \.navigationBar))
        .hideTabBar()
    }
}

