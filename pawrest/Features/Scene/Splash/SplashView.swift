//
//  SplashView.swift
//  pawrest
//
//  Created by 곽예리 on 7/12/26.
//

import SwiftUI
import ComposableArchitecture

struct SplashView: View {
    let store: StoreOf<SplashReducer>
    
    var body: some View {
        ZStack {
            Color.pawPrimary
                .ignoresSafeArea()
            
            Image(.splashLogo)
                .resizable()
                .scaledToFit()
                .frame(width: 114, height: 144)
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    SplashView(
        store: Store(initialState: SplashState()){
            SplashReducer()
        }
    )
}
