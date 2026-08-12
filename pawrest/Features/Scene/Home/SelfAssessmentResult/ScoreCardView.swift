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
            
            Image(.imageSelfAssessmentResult)
                .resizable()
                .scaledToFit()
                .frame(width: 105, height: 28)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 112)
                .padding(.top, 12)
            
            Spacer().frame(height: 20)
            
            Image(level.backgroundIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
                .padding(.horizontal, 20)
            
            Spacer().frame(height: 18)
            
            Text(title)
                .typography(.pageTitle)
                .foregroundStyle(.gray90)
                .padding(.horizontal, 20)
            
            Spacer().frame(height: 10)
            
            Text(level.label)
                .typography(.body3R)
                .foregroundStyle(.gray70)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.gray20)
                .cornerRadius(10, corners: .allCorners)
                .padding(.horizontal, 20)
            
            Spacer().frame(height: 22)
            
            dashedDivider
                .padding(.horizontal, 20)
            
            Spacer().frame(height: 22)
            
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("\(score)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(level.scoreColor)
                Text("/ \(maxScore)")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(.gray60)
            }
            .padding(.horizontal, 20)
            
            Spacer().frame(height: 12)
            
            ScoreProgressBar(score: score, maxScore: maxScore, color: level.scoreColor)
                .padding(.horizontal, 20)
            
            Spacer().frame(height: 34)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .cornerRadius(20, corners: .allCorners)
        .overlay(
            RoundedCorner(radius: 20, corners: .allCorners)
                .stroke(.pawSecondary, lineWidth: 4)
        )
    }
    
    private var dashedDivider: some View {
        GeometryReader { geo in
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: geo.size.width, y: 0))
            }
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            .foregroundStyle(Color.gray20)
        }
        .frame(height: 1)
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
                    .fill(.gray20)
                    .frame(height: 10)
                
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
                    .frame(width: geo.size.width * progress, height: 10)
            }
        }
        .frame(height: 8)
    }
}
