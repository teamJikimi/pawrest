//
//  AddMemoryView.swift
//  pawrest
//
//  Created by 소은 on 5/21/26.
//

import SwiftUI
import ComposableArchitecture

struct AddMemoryView: View {
    @Bindable var store: StoreOf<AddMemoryReducer>
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    AddImageGridView(
                        store: store.scope(
                            state: \.imageGrid,
                            action: \.imageGrid
                        )
                    )
                    .frame(height: 155)
                    .padding(.top, 20)
                    
                    TextField(
                        "제목을 입력하세요.",
                        text: Binding(
                            get: { store.title },
                            set: { store.send(.titleChanged($0)) }
                        )
                    )
                    .typography(.body2R1)
                    .padding(.horizontal, 20)
                    
                    Divider()
                        .background(.gray20)
                        .padding(.horizontal, 20)
                    
                    LimitedTextField(
                        text: Binding(
                            get: { store.content },
                            set: { store.send(.contentChanged($0)) }
                        ),
                        isFocused: $isFocused,
                        placeholder: "떠오르는 순간을 적어보세요.\n기록은 마음을 정리하는 작은 시작이 될 수 있어요.",
                        maxCharacters: 1000
                    )
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
                
                Button {
                    store.send(.saveButtonTapped)
                } label: {
                    Text("저장하기")
                        .typography(.body1M)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(.gray80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .customNavigationBar(
            store: store.scope(
                state: \.navigationBar,
                action: \.navigationBar
            )
        )
    }
}
