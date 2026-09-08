//
//  ReportCounselingSectionView.swift
//  pawrest
//
//  Created by 소은 on 9/3/26.
//

import SwiftUI

struct ReportCounselingSectionView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(uiImage: .imagePlus)
                        .resizable()
                        .frame(width: 14, height: 14)
                    Text("전문 상담기관 안내")
                        .typography(.body1M)
                        .foregroundStyle(.gray80)
                }
                Text("많은 분들이 전문 상담으로 마음의 짐을 덜었어요\n힘들 땐 전문 상담기관을 찾아보는 건 어떨까요?")
                    .typography(.caption)
                    .foregroundStyle(.gray60)
                    .lineSpacing(4)
                    .padding(.top, 2)
            }
            counselingRow(name: "정신건강 위기상담전화", number: "1577-0199")
            counselingRow(name: "보건복지콜센터", number: "129")
        }
        .padding(16)
        .background(.rowMuted)
        .cornerRadius(20, corners: .allCorners)
    }

    private func counselingRow(name: String, number: String) -> some View {
        HStack {
            Text(name)
                .typography(.body3R)
                .foregroundStyle(.gray80)
            Spacer()
            Text(number)
                .typography(.body3R)
                .foregroundStyle(.gray80)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(.gray20)
        .cornerRadius(10, corners: .allCorners)
    }
}
