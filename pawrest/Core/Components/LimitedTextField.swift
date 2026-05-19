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
    
    init(
        text: Binding<String>,
        isFocused: FocusState<Bool>.Binding,
        placeholder: String = "떠오르는 순간을 적어보세요.\n기록은 마음을 정리하는 작은 시작이 될 수 있어요.",
        maxCharacters: Int = 1000,
        minHeight: CGFloat = 330
    ) {
        self._text = text
        self._isFocused = isFocused
        self.placeholder = placeholder
        self.maxCharacters = maxCharacters
        self.minHeight = minHeight
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .typography(.body2R2)
                        .foregroundColor(.gray50)
                        .padding()
                        .allowsHitTesting(false)
                }
                
                TextField("", text: $text, axis: .vertical)
                    .typography(.body2R2)
                    .focused($isFocused)
                    .padding()
            }
            .frame(minHeight: minHeight, alignment: .top)
            .background(.gray0)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.gray20, lineWidth: 1)
            )
            .onChange(of: text) { oldValue, newValue in
                if newValue.count > maxCharacters {
                    text = String(newValue.prefix(maxCharacters))
                }
            }
            
            HStack {
                Spacer()
                Text("\(text.count)/\(maxCharacters)")
                    .font(.date)
                    .foregroundColor(text.count >= maxCharacters ? .pawPrimary : .gray40)
                    .padding(.trailing, 20)
                    .padding(.top, 4)
            }
        }
    }
}
