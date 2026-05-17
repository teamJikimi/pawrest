//
//  HomeView.swift
//  pawrest
//
//  Created by 소은 on 5/17/26.
//

import SwiftUI
import ComposableArchitecture

struct HomeView: View {
    let store: StoreOf<HomeFeature>
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(store.text)
                    .font(.title)
                
                Text("카운트: \(store.count)")
                    .font(.largeTitle)
                    .foregroundColor(.green)
                
                HStack(spacing: 20) {
                    Button {
                        store.send(.decrementButtonTapped)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.largeTitle)
                    }
                    
                    Button {
                        store.send(.incrementButtonTapped)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.largeTitle)
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView(store: Store(initialState: HomeFeature.State()) {
        HomeFeature()
    })
}
