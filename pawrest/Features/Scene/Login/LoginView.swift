//
//  LoginView.swift
//  pawrest
//
//  Created by 예리 on 7/9/26.
//

import SwiftUI
import ComposableArchitecture

struct LoginView: View {
    @Bindable var store: StoreOf<LoginReducer>
    
    var body: some View {
        ZStack {
            backgroundSection
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 223)
                
                logoSection
                
                Spacer()
                
                appleLoginButton
                    .padding(.horizontal, 20)
                
                termsText
                    .padding(.top, 10)
                
                Spacer()
                    .frame(height: 126)
            }
        }
        .ignoresSafeArea()
    }
}

// MARK: - Subviews

extension LoginView {
    private var backgroundSection: some View {
        Image(.loginBackground)
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
    
    private var logoSection: some View {
        VStack(spacing: 14) {
            Image(.loginLogo)
                .resizable()
                .scaledToFit()
                .frame(height: 63)
            
            Text("사랑은 시들지 않습니다, 그저 푸르게 자랄 뿐")
                .typography(.body2Accent) // 확인 필요
                .foregroundStyle(.pawPrimary)
        }
    }
    
    private var appleLoginButton: some View {
        Button {
            store.send(.appleLoginButtonTapped)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "apple.logo")
                Text("Apple로 계속하기")
                    .typography(.button)
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(.white)
            .cornerRadius(15, corners: .allCorners)
        }
        .disabled(store.isLoading)
    }
    
    private var termsText: some View {
        Text("계속 진행하면 서비스 이용약관과 개인정보 처리방침에 동의하게 돼요")
            .typography(.body4R)
            .foregroundStyle(.gray60)
            .padding(.horizontal, 20)
    }
}

