//
//  AppColor.swift
//  pawrest
//
//  Created by 소은 on 5/18/26.
//


import SwiftUI

enum AppColor {
    // MARK: - Primary Colors
    
    /// Accent color (yellow) - #FDD768
    case accent
    
    /// Primary brand color (green) - #69BB92
    case pawPrimary
    
    /// Light primary color
    case primaryLight
    
    /// Secondary color (beige) - #EDD9C5
    case secondary
    
    // MARK: - Button Colors
    
    /// Primary button color (green)
    case primaryButton
    
    /// Secondary button color
    case secondaryButton
    
    // MARK: - Content Colors
    
    /// Primary content text color
    case contentsPrimary
    
    /// Secondary content text color
    case contentsSecondary
    
    // MARK: - Grayscale
    
    case gray0
    case gray10
    case gray20
    case gray30
    case gray40
    case gray50
    case gray60
    case gray70
    case gray80
    case gray90
    
    // MARK: - Semantic Colors
    
    case black
    case border
    case dim
    case link
    
    // MARK: - Row/List Colors
    
    case rowBg
    case rowHover
    case rowMuted
    
    // MARK: - Color Conversion
    
    var color: Color {
        switch self {
        // Primary
        case .accent: return Color("accent")
        case .pawPrimary: return Color("paw_primary")
        case .primaryLight: return Color("primary_light")
        case .secondary: return Color("secondary")
            
        // Button
        case .primaryButton: return Color("primary_button")
        case .secondaryButton: return Color("secondary_button")
            
        // Content
        case .contentsPrimary: return Color("contents_primary")
        case .contentsSecondary: return Color("contents_secondary")
            
        // Grayscale
        case .gray0: return Color("gray0")
        case .gray10: return Color("gray10")
        case .gray20: return Color("gray20")
        case .gray30: return Color("gray30")
        case .gray40: return Color("gray40")
        case .gray50: return Color("gray50")
        case .gray60: return Color("gray60")
        case .gray70: return Color("gray70")
        case .gray80: return Color("gray80")
        case .gray90: return Color("gray90")
            
        // Semantic
        case .black: return Color("black")
        case .border: return Color("border")
        case .dim: return Color("dim")
        case .link: return Color("link")
            
        // Row
        case .rowBg: return Color("row_bg")
        case .rowHover: return Color("row_hover")
        case .rowMuted: return Color("row_muted")
        }
    }
}

