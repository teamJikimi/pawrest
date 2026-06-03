//
//  InsightBox.swift
//  pawrest
//
//  Created by 소은 on 6/1/26.
//

import SwiftUI

struct InsightBox: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            insightLabel
            insightText
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.94, green: 0.97, blue: 0.95))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private extension InsightBox {
    var insightLabel: some View {
        HStack(spacing: 4) {
            Image(.imagesInsight)
                .resizable()
                .frame(width: 12, height: 6)
            Text("인사이트")
                .typography(.body2M)
                .foregroundColor(.gray80)
        }
    }

    var insightText: some View {
        Text(text)
            .typography(.body4R)
            .foregroundColor(.gray60)
            .lineSpacing(4)
            .lineLimit(4)
    }
}

