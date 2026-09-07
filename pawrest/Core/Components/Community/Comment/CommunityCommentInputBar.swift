//
//  CommunityCommentInputBar.swift
//  pawrest
//
//  Created by Moon AYoung on 5/29/26.
//

import SwiftUI

// MARK: - TopRoundedBorder

struct TopRoundedBorder: Shape {
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
        path.addArc(
            center: CGPoint(x: rect.minX + radius, y: rect.minY + radius),
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        path.addArc(
            center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius),
            radius: radius,
            startAngle: .degrees(270),
            endAngle: .degrees(0),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        return path
    }
}

// MARK: - View

struct CommunityCommentInputBar: View {
    
    //MARK: - Properties
    
    @Binding var text: String
    let onSend: () -> Void
    
    var placeholder: String = "댓글을 입력하세요."
    @FocusState.Binding var isFocused: Bool
    
    private var safeAreaBottom: CGFloat {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first
        else { return 0 }
        return window.safeAreaInsets.bottom
    }
    
    //MARK: - Body
    
    var body: some View {
        textFieldContainer
            .padding(.horizontal, 20)
            .padding(.top, isFocused ? 8 : 18)
            .padding(.bottom, isFocused ? 8 : max(36 - safeAreaBottom, 0))
        
            .frame(maxWidth: .infinity)
            .background(.gray0)
            .cornerRadius(isFocused ? 0 : 20, corners: [.topRight, .topLeft])
            .overlay {
                TopRoundedBorder(radius: isFocused ? 0 : 20)
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
        .padding(.vertical, 8)
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
        Button(action: onSend) {
            Image(text.isEmpty ? .iconSendDefault : .iconSendActive)
                .resizable()
                .scaledToFit()
                .frame(width: 26, height: 26)
        }
        .buttonStyle(.plain)
        .disabled(text.isEmpty)
    }
}

// MARK: - Preview

private struct PreviewWrapper: View {
    @State private var text: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack {
            Spacer()
            CommunityCommentInputBar(
                text: $text,
                onSend: {},
                placeholder: "댓글을 입력하세요.",
                isFocused: $isFocused
            )
        }
        .background(.gray10)
    }
}
