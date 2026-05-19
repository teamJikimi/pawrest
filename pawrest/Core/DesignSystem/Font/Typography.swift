//
//  Typography.swift
//  pawrest
//
//  Created by 소은 on 4/22/26.
//

import SwiftUI

// MARK: - Font Extension
/// Core/DesignSystem/Typography.swift

extension Font {

    // MARK: Page Title (18px)
    static let pageTitle = Font.system(size: 18, weight: .bold)

    // MARK: Title (16~14px)
    static let title1 = Font.system(size: 16, weight: .bold)
    static let title2 = Font.system(size: 14, weight: .semibold)

    // MARK: Button (14px)
    static let button = Font.system(size: 14, weight: .semibold)

    // MARK: Body1 (14px)
    static let body1Accent = Font.system(size: 14, weight: .regular)
    static let body1M      = Font.system(size: 14, weight: .regular)
    static let body1R      = Font.system(size: 14, weight: .regular)

    // MARK: Body2 (12px)
    static let body2Accent = Font.system(size: 12, weight: .semibold)
    static let body2M      = Font.system(size: 12, weight: .regular)
    static let body2R1     = Font.system(size: 12, weight: .regular)
    static let body2R2     = Font.system(size: 12, weight: .regular)

    // MARK: Body3 (11px)
    static let body3Accent = Font.system(size: 11, weight: .semibold)
    static let body3M      = Font.system(size: 11, weight: .semibold)
    static let body3R      = Font.system(size: 11, weight: .semibold)

    // MARK: Date (10px)
    static let date = Font.system(size: 10, weight: .regular)
}

// MARK: - AppTypography (font + tracking + lineSpacing 묶음)
/// lineSpacing = lineHeight - fontSize
/// tracking   = fontSize × letterSpacingRate

struct AppTypography {
    let font: Font
    let tracking: CGFloat
    let lineSpacing: CGFloat

    // MARK: Page Title (18px, lineHeight: 18, tracking: -1%)
    static let pageTitle = AppTypography(font: .pageTitle, tracking: -0.18, lineSpacing: 0)

    // MARK: Title
    // Title1 (16px, lineHeight: 16, tracking: -2%)
    static let title1    = AppTypography(font: .title1,    tracking: -0.32, lineSpacing: 0)
    // Title2 (14px, lineHeight: 14, tracking: -2%)
    static let title2    = AppTypography(font: .title2,    tracking: -0.28, lineSpacing: 0)

    // MARK: Button (14px, lineHeight: 18, tracking: 0%)
    // lineSpacing = 18 - 14 = 4
    static let button    = AppTypography(font: .button,    tracking: 0,     lineSpacing: 4)

    // MARK: Body1 (14px, tracking: -2%)
    // Accent / m : lineHeight 14 → lineSpacing 0
    // r          : lineHeight 20 → lineSpacing 6
    static let body1Accent = AppTypography(font: .body1Accent, tracking: -0.28, lineSpacing: 0)
    static let body1M      = AppTypography(font: .body1M,      tracking: -0.28, lineSpacing: 0)
    static let body1R      = AppTypography(font: .body1R,      tracking: -0.28, lineSpacing: 6)

    // MARK: Body2 (12px, tracking: -2%)
    // Accent / m / r1 : lineHeight 12 → lineSpacing 0
    // r2              : lineHeight 18 → lineSpacing 6
    static let body2Accent = AppTypography(font: .body2Accent, tracking: -0.24, lineSpacing: 0)
    static let body2M      = AppTypography(font: .body2M,      tracking: -0.24, lineSpacing: 0)
    static let body2R1     = AppTypography(font: .body2R1,     tracking: -0.24, lineSpacing: 0)
    static let body2R2     = AppTypography(font: .body2R2,     tracking: -0.24, lineSpacing: 6)

    // MARK: Body3 (11px, lineHeight: 11)
    // Accent : tracking -2%
    // m / r  : tracking -1%
    static let body3Accent = AppTypography(font: .body3Accent, tracking: -0.22, lineSpacing: 0)
    static let body3M      = AppTypography(font: .body3M,      tracking: -0.11, lineSpacing: 0)
    static let body3R      = AppTypography(font: .body3R,      tracking: -0.11, lineSpacing: 0)

    // MARK: Date (10px, lineHeight: 10, tracking: -2%)
    static let date        = AppTypography(font: .date,        tracking: -0.20, lineSpacing: 0)
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
