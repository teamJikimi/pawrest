//
//  OnboardingTextField.swift
//  pawrest
//
//  Created by Moon AYoung on 7/11/26.
//

import SwiftUI

// MARK: - Helper State

enum OnboardingTextFieldHelper: Equatable {
    case none
    case info(String)
    case success(String)
    case error(String)
    
    var text: String? {
        switch self {
        case .none: return nil
        case .info(let t), .success(let t), .error(let t): return t
        }
    }
    
    var color: Color {
        switch self {
        case .none: return .clear
        case .info: return .gray60
        case .success: return .pawPrimary
        case .error: return .danger
        }
    }
}

// MARK: - View

struct OnboardingTextField: View {
    let placeholder: String
    @Binding var text: String
    var helper: OnboardingTextFieldHelper = .none
    var trailingContent: AnyView? = nil
    var isEditable: Bool = true
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            fieldRow
            helperText
        }
    }
}

// MARK: - Subviews

private extension OnboardingTextField {
    
    var fieldRow: some View {
        HStack(spacing: 0) {
            if isEditable {
                TextField(placeholder, text: $text)
                    .typography(.body1M)
                    .foregroundColor(.gray80)
            } else {
                Text(text.isEmpty ? placeholder : text)
                    .typography(text.isEmpty ? .body2R1 : .body1M)
                    .foregroundColor(text.isEmpty ? .gray60 : .gray80)
                
                Spacer()
            }
            
            if let trailing = trailingContent {
                trailing
            }
        }
        .padding(.leading, 20)
        .frame(height: 45)
        .background(.gray10)
        .cornerRadius(10, corners: .allCorners)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.gray20, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
    }
    
    @ViewBuilder
    var helperText: some View {
        if let text = helper.text {
            Text(text)
                .typography(.body4R)
                .foregroundColor(helper.color)
        }
    }
}

// MARK: - Convenience Initializers

extension OnboardingTextField {
    
    static func withDuplicateCheck(
        placeholder: String,
        text: Binding<String>,
        helper: OnboardingTextFieldHelper,
        isButtonEnabled: Bool,
        onCheck: @escaping () -> Void
    ) -> OnboardingTextField {
        OnboardingTextField(
            placeholder: placeholder,
            text: text,
            helper: helper,
            trailingContent: AnyView(
                Button(action: onCheck) {
                    Text("중복체크")
                        .typography(.body2R1)
                        .foregroundColor(.gray0)
                        .padding(.horizontal, 16)
                        .frame(height: 28)
                        .background(isButtonEnabled ? Color.pawPrimary : .gray40)
                        .cornerRadius(10, corners: .allCorners)
                }
                .disabled(!isButtonEnabled)
                .padding(.leading, 20)
                .padding(.trailing, 12)
            )
        )
    }
    
    static func withCalendar(
        placeholder: String,
        text: Binding<String>,
        helper: OnboardingTextFieldHelper = .none,
        onTap: @escaping () -> Void
    ) -> OnboardingTextField {
        OnboardingTextField(
            placeholder: placeholder,
            text: text,
            helper: helper,
            trailingContent: AnyView(
                Image(.iconCalender)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.gray60)
                    .padding(.leading, 16)
                    .padding(.trailing, 16)
            ),
            isEditable: false,
            onTap: onTap
        )
    }
}
