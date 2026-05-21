//
//  MemoryView.swift
//  pawrest
//
//  Created by 소은 on 5/20/26.
//

import SwiftUI
import ComposableArchitecture

struct MemoryView: View {
    @Bindable var store: StoreOf<MemoryReducer>
    
    var body: some View {
        NavigationStack {
            VStack {
                NavigationBarView(
                    store: store.scope(
                        state: \.navigationBar,
                        action: \.navigationBar
                    )
                )
                
                ScrollView {
                    Text("추억 목록이 여기에 표시됩니다")
                        .padding()
                }
            }
            .navigationDestination(
                item: $store.scope(
                    state: \.addMemory,
                    action: \.addMemory
                )
            ) { store in
                AddMemoryView(store: store)
                    .navigationTitle("추억 기록")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
