//
//  Typography.swift
//  pawrest
//
//  Created by 소은 on 4/22/26.
//

import SwiftUI

// MARK: - AppFont
/// Core/DesignSystem/Typography.swift

extension Font {

    // MARK: Headline (24px)
    /// 헤드라인 - Regular
    static let headlineRegular = Font.system(size: 24, weight: .regular)
    /// 헤드라인 - Bold
    static let headlineBold = Font.system(size: 24, weight: .bold)

    // MARK: Title (18px)
    /// 커뮤니티 글 제목 / 마이페이지 이름 - Bold
    static let titleBold = Font.system(size: 18, weight: .bold)

    // MARK: List / Subheadline (14px)
    /// 목록 - Regular
    static let listRegular = Font.system(size: 14, weight: .regular)
    /// 서브헤드라인 - Regular
    static let subheadlineRegular = Font.system(size: 14, weight: .regular)
    /// 서브헤드라인 - Bold
    static let subheadlineBold = Font.system(size: 14, weight: .bold)

    // MARK: Message (13px)
    /// 위로 메시지 - Regular
    static let messageRegular = Font.system(size: 13, weight: .regular)
    /// 위로 메시지 - Semibold
    static let messageSemibold = Font.system(size: 13, weight: .semibold)

    // MARK: Body / Date (12px)
    /// 본문 - Regular
    static let bodyRegular = Font.system(size: 12, weight: .regular)
    /// 날짜 - Regular
    static let dateRegular = Font.system(size: 12, weight: .regular)

    // MARK: Button / Time (10px)
    /// 버튼 - Regular
    static let buttonRegular = Font.system(size: 10, weight: .regular)
    /// 버튼 - Semibold
    static let buttonSemibold = Font.system(size: 10, weight: .semibold)
    /// 시간/날짜 - Regular
    static let timeRegular = Font.system(size: 10, weight: .regular)
    /// 시간/날짜 - Semibold
    static let timeSemibold = Font.system(size: 10, weight: .semibold)
}

// MARK: - AppTypography (font + tracking + lineSpacing 묶음)
/// letter spacing, line height까지 함께 적용할 때 사용
struct AppTypography {

    let font: Font
    let tracking: CGFloat     // letter spacing
    let lineSpacing: CGFloat  // line height에서 font size 뺀 값

    // MARK: Headline (24px, lineHeight: 100%, tracking: -1%)
    static let headlineRegular = AppTypography(font: .headlineRegular, tracking: -0.24, lineSpacing: 0)
    static let headlineBold    = AppTypography(font: .headlineBold,    tracking: -0.24, lineSpacing: 0)

    // MARK: Title (18px, lineHeight: 100%, tracking: -1%)
    static let titleBold       = AppTypography(font: .titleBold,       tracking: -0.18, lineSpacing: 0)

    // MARK: List / Subheadline (14px, lineHeight: 100%, tracking: -2%)
    static let listRegular        = AppTypography(font: .listRegular,        tracking: -0.28, lineSpacing: 0)
    static let subheadlineRegular = AppTypography(font: .subheadlineRegular, tracking: -0.28, lineSpacing: 0)
    static let subheadlineBold    = AppTypography(font: .subheadlineBold,    tracking: -0.28, lineSpacing: 0)

    // MARK: Message (13px, lineHeight: 130%, tracking: -1%)
    // lineSpacing = 13 * 1.3 - 13 = 3.9
    static let messageRegular  = AppTypography(font: .messageRegular,  tracking: -0.13, lineSpacing: 3.9)
    static let messageSemibold = AppTypography(font: .messageSemibold, tracking: -0.13, lineSpacing: 3.9)

    // MARK: Body (12px, lineHeight: 140%, tracking: -1%)
    // lineSpacing = 12 * 1.4 - 12 = 4.8
    static let bodyRegular     = AppTypography(font: .bodyRegular,     tracking: -0.12, lineSpacing: 4.8)

    // MARK: Date (12px, lineHeight: 100%, tracking: -1%)
    static let dateRegular     = AppTypography(font: .dateRegular,     tracking: -0.12, lineSpacing: 0)

    // MARK: Button / Time (10px, lineHeight: 100%, tracking: -2%)
    static let buttonRegular   = AppTypography(font: .buttonRegular,   tracking: -0.20, lineSpacing: 0)
    static let buttonSemibold  = AppTypography(font: .buttonSemibold,  tracking: -0.20, lineSpacing: 0)
    static let timeRegular     = AppTypography(font: .timeRegular,     tracking: -0.20, lineSpacing: 0)
    static let timeSemibold    = AppTypography(font: .timeSemibold,    tracking: -0.20, lineSpacing: 0)
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
