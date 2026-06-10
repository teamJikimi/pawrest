//
//  PrivacyPolicyView.swift
//  pawrest
//
//  Created by 소은 on 6/6/26.
//

import SwiftUI
import ComposableArchitecture

struct PrivacyPolicyView: View {
    @Bindable var store: StoreOf<PrivacyPolicyFeature>
    
    // MARK: - View
    var body: some View {
        ZStack {
            ScrollView {
                // 추후 구현
            }
            
            Text("개인정보 처리방침만드는중 ..")
                .typography(.body1R)
                .foregroundStyle(.gray60)
        }
        .background(.gray0)
        .customNavigationBar(store: store.scope(state: \.navigationBar, action: \.navigationBar))
    }
}
