//
//  TermsOfServiceView.swift
//  pawrest
//
//  Created by 소은 on 8/12/26.
//

import SwiftUI
import ComposableArchitecture

struct TermsOfServiceView: View {
    @Bindable var store: StoreOf<TermsOfServiceFeature>
    
    var body: some View {
        ZStack {
            ScrollView {
                // 추후 구현
            }
            
            Text("이용약관 추가 예정")
                .typography(.body1R)
                .foregroundStyle(.gray60)
        }
        .background(.gray0)
        .customNavigationBar(store: store.scope(state: \.navigationBar, action: \.navigationBar))
    }
}
