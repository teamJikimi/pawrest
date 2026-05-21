//
//  MemoryView.swift
//  pawrest
//
//  Created by 소은 on 5/17/26.
//

import SwiftUI
import ComposableArchitecture

struct MemoryView: View {
    @Bindable var store: StoreOf<MemoryReducer>
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Spacer()
            }
            .customNavigationBar(
                store: store.scope(
                    state: \.navigationBar,
                    action: \.navigationBar
                )
            )
            .fullScreenCover(
                item: $store.scope(
                    state: \.addMemory,
                    action: \.addMemory
                )
            ) { addMemoryStore in
                AddMemoryView(store: addMemoryStore)
                    .toolbar(.hidden, for: .navigationBar)
                    .navigationBarBackButtonHidden(true)
            }
        }
        .navigationViewStyle(.stack)
    }
}
