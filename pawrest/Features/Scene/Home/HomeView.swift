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
            VStack {
                Text("홈 화면")
            }
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
    
}
