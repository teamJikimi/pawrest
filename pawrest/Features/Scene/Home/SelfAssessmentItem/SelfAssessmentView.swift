//
//  SelfAssessmentView.swift
//  pawrest
//
//  Created by Moon AYoung on 6/16/26.
//

import SwiftUI
import ComposableArchitecture

struct SelfAssessmentView: View {
    
    //MARK: - Properties
    
    @Bindable var store: StoreOf<SelfAssessmentReducer>
    @Environment(\.dismiss) private var dismiss
    
    //MARK: - Body
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                    cardsSection
                    submitButton
                }
                .padding(.horizontal, 20)
            }
            .background(.gray10)
            
            //            .onChange(of: store.firstUnansweredIndex) { _, _ in
            //
            //            }
            //            .onReceive(
            //                NotificationCenter.default.publisher(for: .init("scrollToUnanswered"))
            //            ) { _ in
            //                if let index = store.firstUnansweredIndex {
            //                    withAnimation {
            //                        proxy.scrollTo("question_\(index)", anchor: .top)
            //                    }
            //                }
            //            }
            .onChange(of: store.scrollTargetIndex) { _, targetIndex in
                if let targetIndex {
                    withAnimation {
                        proxy.scrollTo("question_\(targetIndex)", anchor: .top)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    store.send(.backButtonTapped)
                } label: {
                    Image(.iconBack)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
            }
        }
        .onChange(of: store.shouldDismiss) { _, shouldDismiss in
            if shouldDismiss { dismiss() }
        }
        .alert(
            "검사를 종료할까요?",
            isPresented: Binding(
                get: { store.showExitAlert },
                set: { if !$0 { store.send(.exitAlertCancelled) } }
            )
        ) {
            Button("취소", role: .cancel) {
                store.send(.exitAlertCancelled)
            }
            Button("확인", role: .destructive) {
                store.send(.exitAlertConfirmed)
            }
        } message: {
            Text("지금 나가면 응답 내용이 저장되지 않아요.")
        }
        
        .navigationDestination(
            isPresented: Binding(
                get: { store.isResultPresented },
                set: { if !$0 { store.send(.resultDismissed) } }
            )
        ) {
            if let score = store.totalScore {
                SelfAssessmentResultView(
                    store: Store(
                        initialState: SelfAssessmentResultState(
                            assessmentType: store.type.toResultType,
                            score: score
                        ),
                        reducer: { SelfAssessmentResultFeature() }
                    )
                )
            }
        }
    }
}

// MARK: - Subviews

private extension SelfAssessmentView {
    
    var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(store.type.title)
                .typography(.title1)
                .foregroundColor(.gray90)
                .padding(.top, 16)
            
            HStack(spacing: 6) {
                headerTag(
                    "\(store.type.questionCount)문항",
                    background: .gray80
                )
                headerTag(
                    store.type.estimatedTime,
                    background: .pawPrimary
                )
            }
            .padding(.top, 10)
            
            Text(store.type.instruction)
                .typography(.body2R2)
                .foregroundColor(.gray70)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.gray20)
                .cornerRadius(20, corners: .allCorners)
                .padding(.top, 10)
        }
    }
    
    var cardsSection: some View {
        VStack(spacing: 8) {
            ForEach(Array(store.questions.enumerated()), id: \.element.id) { index, question in
                SelfAssessmentQuestionCard(
                    question: question,
                    category: store.type.questionCategory,
                    options: store.type.options,
                    selectedIndex: store.answers[index],
                    onOptionSelected: { optionIndex in
                        store.send(.optionSelected(questionIndex: index, optionIndex: optionIndex))
                    }
                )
                .id("question_\(index)")
            }
        }
        .padding(.top, 16)
    }
    
    var submitButton: some View {
        Button {
            store.send(.submitTapped)
        } label: {
            Text("결과 확인하기")
                .typography(.button)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(.pawPrimary)
                .cornerRadius(14, corners: .allCorners)
        }
        .padding(.top, 28)
        .padding(.bottom, 36)
    }
    
    func headerTag(_ text: String, background: Color) -> some View {
        Text(text)
            .typography(.body2R1)
            .foregroundColor(.gray0)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(background)
            .cornerRadius(6, corners: .allCorners)
    }
}
