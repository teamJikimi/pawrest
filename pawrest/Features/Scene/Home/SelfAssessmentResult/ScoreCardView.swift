//
//  ScoreCardView.swift
//  pawrest
//
//  Created by 소은 on 6/14/26.
//

import SwiftUI

struct ScoreCardView: View {
    let title: String
    let score: Int
    let maxScore: Int
    let level: AssessmentScoreLevel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .typography(.title1)
                .foregroundStyle(.gray90)
            
            Spacer().frame(height: 10)
            
            Text(level.label)
                .typography(.body3R)
                .foregroundStyle(level.scoreColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(level.badgeBackground)
                .cornerRadius(6, corners: .allCorners)
            
            Spacer().frame(height: 35)
            
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("\(score)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(level.scoreColor)
                Text("/ \(maxScore)")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(.gray60)
            }
            
            Spacer().frame(height: 10)
            
            ScoreProgressBar(
                score: score,
                maxScore: maxScore,
                color: level.scoreColor
            )
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(level.cardGradient)
        .cornerRadius(20, corners: .allCorners)
        .overlay(
            RoundedCorner(radius: 20, corners: .allCorners)
                .stroke(level.scoreColor.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - ScoreProgressBar

private struct ScoreProgressBar: View {
    let score: Int
    let maxScore: Int
    let color: Color
    
    private var progress: CGFloat {
        guard maxScore > 0 else { return 0 }
        return min(CGFloat(score) / CGFloat(maxScore), 1.0)
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray20)
                    .frame(height: 8)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: color.opacity(0.5), location: 0),
                                .init(color: color, location: 1)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * progress, height: 8)
            }
        }
        .frame(height: 8)
    }
}
