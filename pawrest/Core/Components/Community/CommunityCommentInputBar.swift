//
//  CommunityCommentInputBar.swift
//  pawrest
//
//  Created by Moon AYoung on 5/29/26.
//

import SwiftUI

struct CommunityCommentInputBar: View {
    
    //MARK: - Properties
    
    @Binding var text: String
    let onSend: () -> Void
    
    var placeholder: String = "댓글을 입력하세요."
    @FocusState.Binding var isFocused: Bool
    
    //MARK: - Body
    
    var body: some View {
        textFieldContainer
            .padding(.horizontal, 20)
            .padding(.top, isFocused ? 8 : 18)
        //.padding(.bottom, isFocused ? 12 : 0)
        
            .frame(maxWidth: .infinity)
            .background(.gray0)
            .cornerRadius(isFocused ? 0 : 20, corners: [.topRight, .topLeft])
            .overlay {
                RoundedCorner(
                    radius: isFocused ? 0 : 20,
                    corners: [.topRight, .topLeft]
                )
                .stroke(.gray10, lineWidth: 1)
            }
            .background(
                Color.gray0.ignoresSafeArea(.container, edges: .bottom)
            )
            .animation(.easeInOut(duration: 0.25), value: isFocused)
        
    }
}


//MARK: - Layouts

private extension CommunityCommentInputBar {
    
    var textFieldContainer: some View {
        HStack(alignment: .bottom, spacing: 15) {
            textField
            sendButton
        }
        .padding(.leading, 14)
        .padding(.trailing, 8)
        .padding(.vertical, 12)
        .background(.gray0)
        .cornerRadius(20, corners: .allCorners)
        .overlay {
            RoundedCorner(radius: 20, corners: .allCorners)
                .stroke(.gray30, lineWidth: 1)
        }
    }
}

//MARK: - Subviews

private extension CommunityCommentInputBar {
    
    var textField: some View {
        TextField(placeholder, text: $text, axis: .vertical)
            .typography(.body2R1)
            .lineSpacing(4)
            .foregroundColor(.gray80)
            .lineLimit(1...5)
            .focused($isFocused)
            .frame(minHeight: 24, alignment: .center)
    }
    
    var sendButton: some View {
        Button(action: onSend){
            Image(text.isEmpty ? .iconSendDefault : .iconSendActive)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
        }
        .buttonStyle(.plain)
        .disabled(text.isEmpty)
    }
}
