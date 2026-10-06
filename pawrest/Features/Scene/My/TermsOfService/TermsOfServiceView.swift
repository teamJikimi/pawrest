//
//  TermsOfServiceView.swift
//  pawrest
//
//  Created by 소은 on 8/12/26.
//

import SwiftUI
import ComposableArchitecture

struct TermsOfServiceView: View {
    @Bindable var store: StoreOf<TermsOfServiceFeature>

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                article1
                article2
                article3
                article4
                article5
                article6
                article7
                article8
                article9
                article10
                article11
                article12
                article13
                article14
                article15
                article16
                effectiveDate
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(.gray0)
        .customNavigationBar(store: store.scope(state: \.navigationBar, action: \.navigationBar))
        .hideTabBar()
    }
}

// MARK: - Sections

private extension TermsOfServiceView {

    var article1: some View {
        articleSection(title: "제1조. 목적") {
            bodyText("본 약관은 팀 지키미(이하 \"회사\")가 제공하는 반려동물 상실 애도 지원 서비스 Pawrest(이하 \"서비스\")의 이용 조건 및 절차, 회사와 회원 간의 권리·의무 및 책임사항을 규정함을 목적으로 합니다.")
        }
    }

    var article2: some View {
        articleSection(title: "제2조. 약관의 게시와 개정") {
            numberedItems([
                "회사는 회원이 본 약관을 쉽게 확인할 수 있도록 서비스 내 \"마이 > 계정관리\" 화면에 게시하고, 로그인 화면에서 이를 안내합니다.",
                "회사는 관련 법령에 위배되지 않는 범위에서 본 약관을 개정할 수 있습니다.",
                "약관을 개정하는 경우 적용일자와 개정 사유를 명시하여 적용일 7일 전부터 서비스 내에 공지합니다. 회원에게 불리하거나 중대한 변경은 적용일 30일 전부터 공지합니다.",
                "회원은 개정 약관에 동의하지 않을 권리가 있으며, 이 경우 서비스 이용을 중단하고 탈퇴할 수 있습니다. 회사가 제3항의 공지를 하면서 \"적용일까지 거부 의사를 표시하지 않으면 동의한 것으로 본다\"는 뜻을 명확히 알렸음에도 회원이 거부 의사를 표시하지 않고 서비스를 계속 이용하는 경우 개정 약관에 동의한 것으로 봅니다."
            ])
        }
    }

    var article3: some View {
        articleSection(title: "제3조. 용어의 정의") {
            numberedItems([
                "서비스: 회원이 이용할 수 있는 Pawrest 관련 제반 기능(감정기록, AI 주간 리포트, 심리 자가진단, 디지털 추모공간, 추억앨범, 커뮤니티 등)",
                "회원: 본 약관에 동의하고 회원가입을 완료하여 서비스를 이용하는 자",
                "반려동물 프로필: 회원이 등록한 반려동물의 정보",
                "추모편지: 회원이 디지털 추모공간에서 작성·전송하는 편지",
                "게시물: 회원이 커뮤니티에 게시하는 문자, 이미지 등의 정보"
            ])
        }
    }

    var article4: some View {
        articleSection(title: "제4조. 이용계약의 체결") {
            numberedItems([
                "이용계약은 가입 신청자가 로그인 화면에서 본 약관 및 개인정보처리방침에 관한 안내를 확인하고, Apple 로그인으로 가입 절차를 완료함으로써 체결됩니다.",
                "서비스는 만 14세 이상만 가입할 수 있습니다.",
                "회사는 다음의 경우 가입을 승낙하지 않거나 사후에 이용계약을 해지할 수 있습니다.\n   • 만 14세 미만인 경우\n   • 허위 정보를 기재하거나 필수 정보를 입력하지 않은 경우\n   • 부정한 목적으로 서비스를 이용하고자 하는 경우\n   • 타인의 정보를 도용한 경우",
                "회원은 언제든지 \"마이 > 계정관리 > 계정탈퇴\"를 통해 이용계약을 해지할 수 있습니다. 탈퇴하면 로그인 계정과 회원이 작성한 커뮤니티 게시물·댓글이 삭제되며 복구할 수 없습니다. 닉네임, 프로필 사진, 반려동물 프로필 정보는 이메일로 삭제를 요청하면 삭제합니다. 회원의 기기에 저장된 데이터는 앱을 삭제하면 삭제됩니다."
            ])
        }
    }

    var article5: some View {
        articleSection(title: "제5조. 개인정보의 보호") {
            bodyText("회사는 관련 법령 및 개인정보처리방침에 따라 회원의 개인정보를 보호합니다. 감정기록, 심리 자가진단 결과, 추모편지, 추억앨범 등은 회원의 기기에만 저장되며, AI 주간 리포트를 생성할 때 그 일부가 외부 AI 서비스로 전송됩니다. 구체적인 처리 내용은 개인정보처리방침에서 정합니다.")
        }
    }

    var article6: some View {
        articleSection(title: "제6조. 계정 및 기기 내 데이터의 관리") {
            numberedItems([
                "계정의 관리 책임은 회원 본인에게 있으며, 회원은 계정을 제3자가 이용하게 해서는 안 됩니다.",
                "회원은 계정 도용이나 부정 사용을 알게 된 경우 즉시 회사에 알려야 하며, 알리지 않아 발생한 불이익에 대해 회사는 책임지지 않습니다.",
                "회원의 기기에만 저장되는 데이터는 앱을 삭제하거나 기기를 변경·초기화하면 사라지며, 회사는 이를 복구할 수 없습니다."
            ])
        }
    }

    var article7: some View {
        articleSection(title: "제7조. 회사의 의무") {
            numberedItems([
                "회사는 안정적인 서비스 제공을 위해 노력합니다.",
                "회사는 감정기록 패턴을 통해 위험 신호가 감지될 경우 회원에게 전문 상담기관 정보를 안내합니다. 다만 이는 의료적 진단이나 치료를 대체하지 않으며, 모든 위험 상황을 감지함을 보장하지 않습니다.",
                "시스템 점검, 장애 등 불가피한 사유로 서비스가 일시 중단될 수 있으며, 이 경우 회사는 사전 또는 사후에 공지합니다."
            ])
        }
    }

    var article8: some View {
        articleSection(title: "제8조. AI 리포트 및 심리 자가진단의 성격") {
            numberedItems([
                "AI 주간 리포트는 회원의 감정기록과 심리 자가진단 결과 등을 바탕으로 생성형 AI(Google Gemini)가 작성한 참고용 정보이며, 내용이 부정확하거나 회원의 실제 상태와 다를 수 있습니다.",
                "심리 자가진단(PBQ·CES-D·PDS)은 자기 보고식 선별 도구이며, 그 결과는 의학적·심리학적 진단이 아닙니다.",
                "서비스는 의료 행위나 전문 심리 상담이 아니며 이를 대체하지 않습니다. 도움이 필요한 경우 정신건강 위기상담전화(1577-0199), 보건복지상담센터(129) 등 전문기관에 상담하시기 바랍니다."
            ])
        }
    }

    var article9: some View {
        articleSection(title: "제9조. 회원의 의무") {
            numberedItems([
                "회원은 다음 행위를 해서는 안 됩니다.\n   • 허위 정보 등록, 타인 정보 도용\n   • 회사 또는 다른 회원을 사칭하는 행위\n   • 다른 회원 또는 제3자를 모욕·위협·명예훼손하거나 괴롭히는 행위\n   • 음란·폭력·혐오 등 불쾌감을 주는 내용을 게시하는 행위\n   • 커뮤니티 내 광고성·스팸 게시물 등록\n   • 자동화 프로그램을 이용한 비정상적 서비스 이용\n   • 타인의 감정기록, 심리검사 결과 등 민감한 정보를 무단으로 수집·공개하는 행위\n   • 관계 법령 및 본 약관에 위배되는 행위",
                "회사는 불쾌하거나 유해한 콘텐츠와 다른 회원을 괴롭히는 행위를 용인하지 않습니다. 위반 시 회사는 위반 정도에 따라 게시물 삭제, 이용 제한, 이용계약 해지 등의 조치를 할 수 있습니다."
            ])
        }
    }

    var article10: some View {
        articleSection(title: "제10조. 서비스의 제공 및 변경") {
            numberedItems([
                "회사는 서비스의 형태·기능을 필요에 따라 변경할 수 있으며, 회원에게 불리한 변경의 경우 사전에 공지합니다.",
                "무료로 제공되는 서비스가 변경·중단되는 경우, 관련 법령에 특별한 규정이 없는 한 별도로 보상하지 않습니다."
            ])
        }
    }

    var article11: some View {
        articleSection(title: "제11조. 게시물의 관리") {
            numberedItems([
                "커뮤니티 게시물의 관리 책임은 게시자 본인에게 있습니다.",
                "회사는 다음에 해당하는 게시물을 사전 통지 없이 삭제하거나 노출을 제한할 수 있습니다.\n   • 다른 회원에게 심한 모욕을 주거나 명예를 훼손하는 내용\n   • 음란·폭력·혐오 등 공서양속에 위반되는 내용\n   • 타인의 저작권 등 권리를 침해하는 내용\n   • 반려동물 상실 애도 커뮤니티의 목적에 반하는 내용(예: 광고, 조롱성 게시물)",
                "회원은 부적절한 게시물·댓글을 앱 내 신고 기능으로 신고할 수 있고, 차단 기능으로 특정 회원을 차단할 수 있습니다.",
                "회사는 신고를 접수한 때부터 24시간 이내에 검토하며, 위반이 확인되면 해당 게시물을 삭제하고 작성한 회원의 서비스 이용을 제한합니다. 처리 결과는 신고자에게 안내할 수 있습니다.",
                "게시물 및 서비스 이용과 관련한 문의는 dlathdms1206@gmail.com로 할 수 있습니다."
            ])
        }
    }

    var article12: some View {
        articleSection(title: "제12조. 게시물의 저작권") {
            numberedItems([
                "회원이 작성한 콘텐츠(게시물, 추모편지, 추억앨범 콘텐츠 포함)의 저작권은 작성한 회원에게 귀속됩니다.",
                "회사는 서비스 제공 및 운영 목적 범위 내에서만 게시물을 이용하며, 회원의 동의 없이 상업적으로 이용하지 않습니다.",
                "회원이 탈퇴하면 본인이 작성한 게시물은 삭제됩니다. 다만 법령상 보관 의무가 있는 경우는 예외로 합니다."
            ])
        }
    }

    var article13: some View {
        articleSection(title: "제13조. 서비스 이용 제한") {
            numberedItems([
                "회원이 제9조를 위반하거나 다음에 해당하는 경우 서비스 이용이 제한될 수 있습니다.\n   • 가입 시 허위 정보 등록\n   • 타인의 서비스 이용 방해 또는 정보 도용\n   • 범죄와 결부된다고 객관적으로 판단되는 행위",
                "이용 제한에 이의가 있는 회원은 제11조 제5항의 이메일로 이의를 제기할 수 있으며, 회사는 이를 검토하여 결과를 회신합니다."
            ])
        }
    }

    var article14: some View {
        articleSection(title: "제14조. 손해배상 및 면책") {
            numberedItems([
                "회사는 천재지변 등 불가항력으로 서비스를 제공할 수 없는 경우 책임을 지지 않습니다.",
                "회사는 회원의 고의 또는 과실로 발생한 손해에 대해 책임을 지지 않습니다.",
                "회사는 회원이 게시한 콘텐츠의 진위와 신뢰성을 보증하지 않습니다.",
                "AI 주간 리포트와 심리 자가진단 결과는 참고용 정보이며, 회사는 고의 또는 중대한 과실이 없는 한 이를 근거로 한 회원의 판단과 그 결과에 대해 책임을 지지 않습니다.",
                "회사는 고의 또는 중대한 과실이 없는 한 회원 상호 간 또는 회원과 제3자 간에 발생한 분쟁에 대해 책임을 지지 않습니다.",
                "회사는 고의 또는 중대한 과실이 없는 한 앱 삭제, 기기 변경·초기화 등으로 회원의 기기에 저장된 데이터가 사라진 것에 대해 책임을 지지 않습니다."
            ])
        }
    }

    var article15: some View {
        articleSection(title: "제15조. Apple 관련 사항") {
            numberedItems([
                "본 약관은 회사와 회원 사이에 체결되는 것이며, Apple Inc.(이하 \"Apple\")는 본 약관의 당사자가 아닙니다. 서비스와 그 콘텐츠에 대한 책임은 회사에 있습니다.",
                "Apple은 서비스에 대한 유지보수 및 지원 의무를 지지 않습니다.",
                "회원은 서비스를 이용할 때 App Store 서비스 약관에서 정한 사용 규칙을 준수해야 합니다.",
                "Apple과 그 자회사는 본 약관의 제3자 수익자이며, 회원이 본 약관에 동의하면 Apple은 제3자 수익자로서 회원에 대해 본 약관을 집행할 권리를 가집니다."
            ])
        }
    }

    var article16: some View {
        articleSection(title: "제16조. 준거법 및 관할법원") {
            numberedItems([
                "본 약관과 관련한 분쟁은 대한민국 법을 준거법으로 합니다.",
                "관련 소송은 민사소송법상의 관할법원에 제기합니다."
            ])
        }
    }

    var effectiveDate: some View {
        Text("본 약관은 2026년 10월 7일부터 적용됩니다.")
            .typography(.body2R1)
            .foregroundStyle(.gray70)
            .padding(.top, 8)
    }
}

// MARK: - Helpers

private extension TermsOfServiceView {

    func articleSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .typography(.body1Accent)
                .foregroundStyle(.gray90)
            content()
        }
    }

    func bodyText(_ text: String) -> some View {
        Text(text)
            .typography(.body2R1)
            .foregroundStyle(.gray70)
            .fixedSize(horizontal: false, vertical: true)
    }

    func subTitle(_ text: String) -> some View {
        Text(text)
            .typography(.body2Accent)
            .foregroundStyle(.gray80)
    }

    func numberedItems(_ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .top, spacing: 6) {
                    Text("\(index + 1).")
                        .typography(.body2R1)
                        .foregroundStyle(.gray70)
                        .frame(minWidth: 16, alignment: .leading)
                    Text(item)
                        .typography(.body2R1)
                        .foregroundStyle(.gray70)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    func bulletItems(_ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .top, spacing: 6) {
                    Text("•")
                        .typography(.body2R1)
                        .foregroundStyle(.gray70)
                    Text(item)
                        .typography(.body2R1)
                        .foregroundStyle(.gray70)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}
