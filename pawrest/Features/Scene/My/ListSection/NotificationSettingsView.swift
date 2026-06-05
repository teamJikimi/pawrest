//
//  NotificationSettingsView.swift
//  pawrest
//
//  Created by 소은 on 6/5/26.
//

import SwiftUI

struct NotificationSettingsView: View {
    @Binding var emotionReminder: Bool
    @Binding var weeklyReport: Bool
    @Binding var petMemory: Bool
    @Binding var communityReaction: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("알림")
                .typography(.body1M)
                .padding(.horizontal, 8)
            
            VStack(spacing: 0) {
                notificationToggleRow(title: "감정 기록 리마인더", isOn: $emotionReminder)
                Divider().padding(.leading, 16)
                notificationToggleRow(title: "주간 리포트", isOn: $weeklyReport)
                Divider().padding(.leading, 16)
                notificationToggleRow(title: "사별 기록", isOn: $petMemory)
                Divider().padding(.leading, 16)
                notificationToggleRow(title: "커뮤니티 반응", isOn: $communityReaction)
            }
            .background(.white)
            .cornerRadius(20, corners: .allCorners)
        }
        .padding(.top, 20)
        .padding(.bottom, 20 )
        .padding(.horizontal, 16)
        .background(.gray10)
        .cornerRadius(20, corners: .allCorners)
    }
    
    // MARK: - Subviews
    
    private func notificationToggleRow(title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .typography(.body2R1)
                .foregroundStyle(.gray70)
        }
        .tint(.pawPrimary)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

