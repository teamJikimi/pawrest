//
//  SelfAssessmentSelectedOverlay.swift
//  pawrest
//
//  Created by Moon AYoung on 6/15/26.
//

import SwiftUI

struct SelfAssessmentSelectedOverlay: View {
    let type: SelfAssessmentType
    let onStart: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }
            
            modalCard
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

// MARK: - Subviews

private extension SelfAssessmentSelectedOverlay {
    
    var modalCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            closeButton
            titleSection
            tagSection
            Rectangle()
                .fill(.gray20)
                .frame(height: 1)
                .padding(.top, 16)
            disclaimerSection
            startButton
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20, corners: .allCorners)
        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 0)
        .padding(.horizontal, 20)
    }
    
    var closeButton: some View {
        HStack {
            Spacer()
            Button(action: onDismiss) {
                Image(.iconClose)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
        }
    }
    
    var titleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(type.title)
                .typography(.pageTitle)
                .foregroundColor(.gray90)
            
            Text(type.description)
                .typography(.body3R)
                .foregroundColor(.gray80)
        }
        .padding(.top, 4)
    }
    
    var tagSection: some View {
        HStack(spacing: 6) {
            introTag(type.questionCount.description + "문항")
            introTag(type.estimatedTime)
        }
        .padding(.top, 12)
    }
    
    var disclaimerSection: some View {
        Text(type.disclaimer)
            .typography(.caption)
            .foregroundColor(.gray60)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.gray10)
            .cornerRadius(10, corners: .allCorners)
            .padding(.top, 16)
    }
    
    var startButton: some View {
        Button(action: onStart) {
            Text("검사하기")
                .typography(.body2Accent)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(.pawPrimary)
                .cornerRadius(12, corners: .allCorners)
        }
        .padding(.top, 16)
    }
    
    func introTag(_ text: String) -> some View {
        Text(text)
            .typography(.body3M)
            .foregroundColor(.gray80)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(.gray20)
            .cornerRadius(6, corners: .allCorners)
    }
}
