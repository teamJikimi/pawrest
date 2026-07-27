//
//  Typography.swift
//  pawrest
//
//  Created by 소은 on 4/22/26.
//

import SwiftUI

// MARK: - Font Extension

extension Font {

    // MARK: Page Title (18px)
    static let pageTitle = Font.system(size: 18, weight: .bold)

    // MARK: Title (20~14px)
    static let title1 = Font.system(size: 16, weight: .bold)
    static let title2 = Font.system(size: 14, weight: .semibold)
    static let title4 = Font.system(size: 20, weight: .bold)

    // MARK: Button (16px)
    static let button = Font.system(size: 16, weight: .bold)

    // MARK: Body1 (16px)
    static let body1Bold   = Font.system(size: 16, weight: .bold)
    static let body1Accent = Font.system(size: 16, weight: .semibold)
    static let body1M      = Font.system(size: 16, weight: .medium)
    static let body1R      = Font.system(size: 16, weight: .regular)

    // MARK: Body2 (14px)
    static let body2Accent = Font.system(size: 14, weight: .semibold)
    static let body2M      = Font.system(size: 14, weight: .medium)
    static let body2R1     = Font.system(size: 14, weight: .regular)
    static let body2R2     = Font.system(size: 14, weight: .regular)

    // MARK: Body3 (13px)
    static let body3Accent = Font.system(size: 13, weight: .semibold)
    static let body3M      = Font.system(size: 13, weight: .medium)
    static let body3R      = Font.system(size: 13, weight: .regular)

    // MARK: Body4 (12px)
    static let body4R      = Font.system(size: 12, weight: .regular)

    // MARK: Date (12px)
    static let date = Font.system(size: 12, weight: .regular)

    // MARK: Caption (12px)
    static let caption = Font.system(size: 12, weight: .regular)
}

// MARK: - AppTypography

struct AppTypography {
    let font: Font
    let tracking: CGFloat
    let lineSpacing: CGFloat

    // MARK: Page Title (18px, lineHeight: 18, tracking: -1%)
    static let pageTitle = AppTypography(font: .pageTitle, tracking: -0.18, lineSpacing: 0)

    // MARK: Title
    static let title1    = AppTypography(font: .title1,    tracking: -0.32, lineSpacing: 0)
    static let title2    = AppTypography(font: .title2,    tracking: -0.28, lineSpacing: 0)
    static let title4    = AppTypography(font: .title4,    tracking: -0.4,  lineSpacing: 8)

    // MARK: Button (16px, lineHeight: 20, tracking: 0%)
    static let button    = AppTypography(font: .button,    tracking: 0,     lineSpacing: 4)

    // MARK: Body1 (16px, tracking: -2%)
    static let body1Bold   = AppTypography(font: .body1Bold,   tracking: -0.28, lineSpacing: 0)
    static let body1Accent = AppTypography(font: .body1Accent, tracking: -0.28, lineSpacing: 0)
    static let body1M      = AppTypography(font: .body1M,      tracking: -0.28, lineSpacing: 0)
    static let body1R      = AppTypography(font: .body1R,      tracking: -0.28, lineSpacing: 8)

    // MARK: Body2 (14px, tracking: -2%)
    static let body2Accent = AppTypography(font: .body2Accent, tracking: -0.24, lineSpacing: 0)
    static let body2M      = AppTypography(font: .body2M,      tracking: -0.24, lineSpacing: 0)
    static let body2R1     = AppTypography(font: .body2R1,     tracking: -0.24, lineSpacing: 0)
    static let body2R2     = AppTypography(font: .body2R2,     tracking: -0.24, lineSpacing: 6)

    // MARK: Body3 (13px)
    static let body3Accent = AppTypography(font: .body3Accent, tracking: -0.22, lineSpacing: 1)
    static let body3M      = AppTypography(font: .body3M,      tracking: -0.11, lineSpacing: 1)
    static let body3R      = AppTypography(font: .body3R,      tracking: -0.11, lineSpacing: 3)

    // MARK: Body4 (12px)
    static let body4R      = AppTypography(font: .body4R,      tracking: -0.2,  lineSpacing: 4)

    // MARK: Date (12px, lineHeight: 12)
    static let date        = AppTypography(font: .date,        tracking: -0.20, lineSpacing: 0)

    // MARK: Caption (12px, lineHeight: 12)
    static let caption     = AppTypography(font: .caption,     tracking: -0.20, lineSpacing: 1)
}

// MARK: - ViewModifier
struct TypographyModifier: ViewModifier {
    let style: AppTypography

    func body(content: Content) -> some View {
        content
            .font(style.font)
            .tracking(style.tracking)
            .lineSpacing(style.lineSpacing)
    }
}

extension View {
    func typography(_ style: AppTypography) -> some View {
        modifier(TypographyModifier(style: style))
    }
}

// MARK: - 사용법
/*
 // font만 쓸 때
 Text("페이지 제목").font(.pageTitle)
 Text("타이틀").font(.title1)

 // tracking + lineSpacing까지 스펙 그대로
 Text("페이지 제목").typography(.pageTitle)
 Text("본문 (넓은 줄간격)").typography(.body1R)
 Text("버튼").typography(.button)
 Text("날짜").typography(.date)
 */
