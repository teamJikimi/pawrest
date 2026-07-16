//
//  MemorialView.swift
//  pawrest
//
//  Created by 소은 on 5/17/26.
//

import SwiftUI
import ComposableArchitecture
import Lottie

struct MemorialView: View {
    @Bindable var store: StoreOf<MemorialReducer>
    
    var body: some View {
        VStack(spacing: 0) {
            LottieView(animationName: "Flow_9", loopMode: .loop)
                .frame(height: 300)
            
            Spacer()
        }
    }
}
