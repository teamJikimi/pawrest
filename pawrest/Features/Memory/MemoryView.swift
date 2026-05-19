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
            .navigationBar(
                store: store.scope(
                    state: \.navigationBar,
                    action: \.navigationBar
                )
            )
        }
        .navigationViewStyle(.stack)
    }
}
