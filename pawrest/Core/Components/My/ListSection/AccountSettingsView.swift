//
//  AccountSettingsView.swift
//  pawrest
//
//  Created by 소은 on 6/6/26.
//

import SwiftUI

struct AccountSettingsView: View {
    var onBlockedList: () -> Void
    var onPrivacyPolicy: () -> Void
    var onDeleteAccount: () -> Void
    var onLogout: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("계정 관리")
                .typography(.body1M)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                SettingsRow(title: "차단 목록", type: .chevron, action: onBlockedList)
                Divider().padding(.horizontal, 16)
                SettingsRow(title: "개인정보 처리방침", type: .chevron, action: onPrivacyPolicy)
                Divider().padding(.horizontal, 16)
                SettingsRow(title: "앱 버전", type: .value("v.1.0.2"))
                Divider().padding(.horizontal, 16)
                SettingsRow(title: "계정 탈퇴", type: .destructive, action: onDeleteAccount)
                Divider().padding(.horizontal, 16)
                SettingsRow(title: "로그아웃", type: .destructive, action: onLogout)
            }
            .background(.white)
            .cornerRadius(20, corners: .allCorners)
        }
        .padding(.horizontal, 16)
        .padding(.top,20)
        .padding(.bottom, 20)
        .background(.gray10)
        .cornerRadius(20, corners: .allCorners)
    }
}
