//
//  CommunityView.swift
//  pawrest
//
//  Created by 소은 on 5/17/26.
//

import SwiftUI
import ComposableArchitecture

struct CommunityView: View {
    @Bindable var store: StoreOf<CommunityReducer>
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                LimitedTextField(
                    text: Binding(
                        get: { store.text },
                        set: { store.send(.textChanged($0)) }
                    ),
                    isFocused: $isFocused
                )
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .onTapGesture {
                isFocused = false
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
