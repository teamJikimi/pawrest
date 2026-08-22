//
//  LimitedTextField.swift
//  pawrest
//
//  Created by 소은 on 5/19/26.
//

import SwiftUI

struct LimitedTextField: View {
    @Binding var text: String
    @FocusState.Binding var isFocused: Bool

    let placeholder: String
    let maxCharacters: Int
    let minHeight: CGFloat
    let showCounter: Bool
    let isTransparent: Bool
    let typography: AppTypography
    let showPlaceholder: Bool

    init(
        text: Binding<String>,
        isFocused: FocusState<Bool>.Binding,
        placeholder: String = "떠오르는 순간을 적어보세요.\n기록은 마음을 정리하는 작은 시작이 될 수 있어요.",
        maxCharacters: Int = 1000,
        minHeight: CGFloat = 372,
        showCounter: Bool = true,
        isTransparent: Bool = false,
        typography: AppTypography = .body2R2,
        showPlaceholder: Bool = true
    ) {
        self._text = text
        self._isFocused = isFocused
        self.placeholder = placeholder
        self.maxCharacters = maxCharacters
        self.minHeight = minHeight
        self.showCounter = showCounter
        self.isTransparent = isTransparent
        self.typography = typography
        self.showPlaceholder = showPlaceholder
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                if showPlaceholder && text.isEmpty {
                    Text(placeholder)
                        .typography(typography)
                        .foregroundColor(.gray50)
                        .padding(20)
                        .allowsHitTesting(false)
                }

                TextField("", text: $text, axis: .vertical)
                    .typography(typography)
                    .focused($isFocused)
                    .padding(20)
            }
            .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .topLeading)
            .contentShape(Rectangle())
            .onTapGesture {
                isFocused = true
            }
            .background(isTransparent ? Color.clear : .gray0)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isTransparent ? Color.clear : .gray20, lineWidth: 1)
            )
            .onChange(of: text) { oldValue, newValue in
                if newValue.count > maxCharacters {
                    text = String(newValue.prefix(maxCharacters))
                }
            }

            if showCounter {
                HStack {
                    Spacer()
                    Text("\(text.count)/\(maxCharacters)")
                        .font(.date)
                        .foregroundColor(text.count >= maxCharacters ? .pawPrimary : .gray50)
                        .padding(.top, 4)
                }
            }
        }
    }
}
