//
//  PrivacyPolicyView.swift
//  pawrest
//
//  Created by 소은 on 6/6/26.
//

import SwiftUI
import ComposableArchitecture

struct PrivacyPolicyView: View {
    @Bindable var store: StoreOf<PrivacyPolicyFeature>

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                preamble
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

private extension PrivacyPolicyView {

    var preamble: some View {
           bodyText("Pawrest(이하 \'서비스\')를 운영하는 팀 지키미(이하 \'회사\')는 「개인정보 보호법」 제30조에 따라 이용자의 개인정보를 보호하고 관련 고충을 신속히 처리하기 위해 다음과 같이 개인정보처리방침을 수립·공개합니다.")
       }


    var article1: some View {
        articleSection(title: "제1조. 개인정보의 처리 목적") {
            bodyText("회사는 다음 목적을 위해 개인정보를 처리합니다.")
            numberedItems([
                "회원 가입 및 관리: 가입 의사 확인, 본인 식별 및 인증, 회원자격 유지·관리, 부정 이용 방지, 문의 및 민원 처리",
                "반려동물 추모 서비스 제공: 반려동물 프로필 관리, 디지털 추모공간(하늘 편지·추모 나무) 제공, 추억앨범 저장 및 열람, 기념일 알림",
                "감정 관리 및 AI 리포트 제공: 감정기록 저장, 주간 감정 리포트 생성을 위한 AI 분석, 심리 자가진단(PBQ·CES-D·PDS) 결과 저장 및 해석 제공",
                "위험 신호 안내: 최근 감정기록 패턴에 따른 전문 상담기관 안내",
                "커뮤니티 서비스 제공: 게시물·댓글 작성 및 열람, 공감, 알림 발송, 신고 접수 및 처리, 이용자 차단, 부적절 게시물 제재",
                "서비스 개선: 오류 대응 및 서비스 안정화"
            ])
            bodyText("회사는 위 목적 외의 용도로 개인정보를 이용하지 않으며, 목적이 변경되는 경우 「개인정보 보호법」 제18조에 따라 별도 동의를 받는 등 필요한 조치를 합니다.")
        }
    }

    var article2: some View {
        articleSection(title: "제2조. 처리하는 개인정보 항목 및 저장 위치") {
            bodyText("서비스는 정보의 성격에 따라 저장 위치를 구분합니다. 감정기록, 심리 자가진단 결과 등 심리 상태와 관련된 기록은 회사 서버에 저장하지 않고 이용자의 기기에만 저장합니다. 다만 AI 주간 리포트를 생성할 때 그 일부가 외부 AI 서비스로 전송됩니다(제5조).")
            subTitle("1. 회사 서버(Firebase)에 저장되는 정보")
            bulletItems([
                "회원가입(필수): Apple 로그인 식별자, 이메일 주소(이메일 가리기를 선택한 경우 Apple이 제공하는 비공개 주소), 닉네임",
                "프로필(선택): 프로필 사진",
                "반려동물 정보: 이름, 프로필 사진, 생일, 기일 등 반려동물 프로필에 입력한 정보",
                "커뮤니티: 게시물(제목·내용·첨부 사진), 댓글, 공감 내역, 신고 내역, 차단 목록",
                "자동 생성: 푸시 알림 토큰, 접속 기록(접속 일시, IP 주소)"
            ])
            subTitle("2. 이용자의 기기에만 저장되는 정보")
            bulletItems([
                "감정기록: 감정 종류, 메모, 기록 일시",
                "심리 자가진단 결과: PBQ·CES-D·PDS 응답 및 점수, 검사 일시",
                "AI 주간 리포트: 생성된 리포트 내용",
                "추모편지: 편지 내용, 작성 일시",
                "추억앨범: 사진, 글"
            ])
            bodyText("위 2의 정보는 이용자 기기의 앱 저장공간에만 저장되며, 회사 서버에는 저장되지 않습니다.")
            bodyText("다만 AI 주간 리포트를 생성할 때에는 최근 7일간의 감정기록(감정 종류, 기록 일시), 메모 텍스트, 심리 자가진단의 검사 종류·총점·검사일, 반려동물 이름이 외부 AI 서비스로 전송됩니다(제5조). 심리 자가진단의 개별 문항 응답, 닉네임, 이메일 주소는 전송되지 않습니다.")
            bodyText("위험 신호 안내는 기기에 저장된 감정기록만으로 기기 안에서 판단하며, 그 결과는 외부로 전송되지 않습니다.")
            bodyText("기기에만 저장되는 정보는 앱을 삭제하거나 기기를 변경·초기화하면 사라지며, 회사가 복구할 수 없습니다.")
        }
    }

    var article3: some View {
        articleSection(title: "제3조. 개인정보의 처리 및 보유 기간") {
            numberedItems([
                "회사는 회원 탈퇴 시까지 개인정보를 보유하며, 회원이 탈퇴하면 로그인 계정과 회원이 작성한 커뮤니티 게시물·댓글, 공감 내역, 차단 목록, 첨부 사진이 삭제되며 복구할 수 없습니다. 닉네임, 프로필 사진, 반려동물 프로필 정보는 탈퇴 시 자동으로 삭제되지 않으며, 이용자가 제6조에 따라 삭제를 요청하면 지체 없이 삭제합니다. 다만 제2항과 제3항에 해당하는 정보는 해당 기간 동안 보관합니다.",
                "신고 및 제재 처리 기록은 분쟁 대응 및 재발 방지 목적으로 처리 완료 후 최대 1년간 보관한 뒤 파기합니다.",
                "다음의 경우에는 해당 사유가 종료될 때까지 보관합니다.\n   • 법령 위반과 관련한 조사·수사가 진행 중인 경우\n   • 서비스 이용과 관련한 분쟁이 진행 중인 경우",
                "기기에만 저장되는 정보는 이용자가 앱에서 직접 삭제하거나 앱을 삭제하면 삭제됩니다. 회원 탈퇴만으로는 기기에 저장된 정보가 삭제되지 않으므로, 삭제를 원하는 경우 앱을 삭제하시기 바랍니다.",
                "AI 주간 리포트 생성을 위해 전송된 정보는 회사가 별도로 저장하지 않으며, 수탁자의 보관 기간은 제5조에 따릅니다."
            ])
        }
    }

    var article4: some View {
        articleSection(title: "제4조. 개인정보의 제3자 제공") {
            bodyText("회사는 이용자의 개인정보를 제3자에게 제공하지 않습니다. 다만 법령에 특별한 규정이 있거나, 수사기관이 법령에 정해진 절차와 방법에 따라 요구하는 경우는 예외로 합니다.")
        }
    }

    var article5: some View {
        articleSection(title: "제5조. 개인정보 처리의 위탁 및 국외 이전") {
            bodyText("회사는 서비스 제공을 위해 아래와 같이 개인정보 처리 업무를 위탁하고 있습니다. 이 과정에서 개인정보가 국외에 있는 Google LLC의 서버로 이전되며, 이는 「개인정보 보호법」 제28조의8 제1항 제3호 가목(계약 이행을 위한 처리위탁·보관)에 따른 것입니다.")
            delegateTable(
                title: "[Firebase]",
                rows: [
                    ("수탁자(연락처)", "Google LLC (googlekrsupport@google.com)"),
                    ("재위탁·이전받는 자", "없음"),
                    ("위탁 업무", "회원 인증(Authentication), 데이터 저장(Cloud Firestore), 이미지 저장(Cloud Storage), 신고 메일 발송(Cloud Functions), 푸시 알림 발송(Cloud Messaging)"),
                    ("이전되는 항목", "Apple 로그인 식별자, 이메일 주소, 닉네임, 프로필 사진, 반려동물 프로필 정보(이름·사진·생일·기일 등), 커뮤니티 게시물·댓글·첨부 사진, 공감·신고·차단 내역, 푸시 알림 토큰, 접속 기록"),
                    ("이전되는 국가", "미국"),
                    ("이전 시기 및 방법", "회원가입 및 서비스 이용 시점에 암호화된 네트워크를 통해 전송"),
                    ("이전받는 자의 이용 목적", "위 위탁 업무의 수행"),
                    ("보유 및 이용 기간", "회원 탈퇴 또는 삭제 요청 시, 또는 위탁 계약 종료 시까지")
                ]
            )
            delegateTable(
                title: "[AI 주간 리포트 생성]",
                rows: [
                    ("수탁자(연락처)", "주식회사 마인드로직(FactChat 게이트웨이)"),
                    ("재위탁·이전받는 자", "Google LLC (Gemini 모델 제공, googlekrsupport@google.com)"),
                    ("위탁 업무", "AI 주간 리포트 문장 생성"),
                    ("이전되는 항목", "최근 7일간의 감정기록(감정 종류, 기록 일시), 메모 텍스트, 심리 자가진단의 검사 종류·총점·검사일, 반려동물 이름"),
                    ("이전되는 국가", "미국 등 Google 데이터센터 소재 국가"),
                    ("이전 시기 및 방법", "주간 리포트를 생성하는 시점(하루 최대 1회)에 암호화된 네트워크를 통해 전송"),
                    ("이전받는 자의 이용 목적", "위 위탁 업무의 수행"),
                    ("보유 및 이용 기간", "리포트 생성 후 수탁자의 서비스 약관에서 정한 기간 동안 보관 후 삭제")
                ]
            )
            bulletItems([
                "국외 이전을 거부하는 방법과 효과: 이용자는 회원가입을 하지 않거나 회원 탈퇴를 함으로써 국외 이전을 거부할 수 있습니다. 다만 위 이전은 서비스 제공에 반드시 필요하므로, 거부하는 경우 서비스를 이용할 수 없습니다. 감정기록에 메모를 작성하지 않거나 심리 자가진단을 하지 않으면 해당 항목은 전송되지 않습니다.",
                "마인드로직은 FactChat 이용약관에 따라 사전 동의 없이 전송된 내용을 AI 학습에 이용하지 않습니다.",
                "회사는 수탁자와의 계약(서비스 약관 및 데이터 처리 약관)에 따라 수탁자가 개인정보를 안전하게 처리하는지 관리·감독합니다.",
                "위탁 업무의 내용이나 수탁자가 변경되는 경우 본 방침을 통해 지체 없이 공개합니다."
            ])
        }
    }

    var article6: some View {
        articleSection(title: "제6조. 정보주체의 권리와 행사 방법") {
            numberedItems([
                "이용자는 언제든지 다음 권리를 행사할 수 있습니다.\n   • 개인정보 열람 요구\n   • 오류 등이 있는 경우 정정 요구\n   • 삭제 요구\n   • 처리정지 요구",
                "권리 행사는 앱 내 기능(프로필 수정, 게시물·댓글 수정 및 삭제, \"마이 > 계정관리 > 계정탈퇴\" 등) 또는 이메일(dlathdms1206@gmail.com)을 통해 할 수 있으며, 회사는 요청을 받은 날부터 10일 이내에 조치합니다.",
                "기기에만 저장되는 정보(제2조 제2호)는 이용자가 앱에서 직접 열람·수정·삭제할 수 있습니다. 회사는 해당 정보를 보유하지 않으므로 이를 대신 열람하거나 복구할 수 없습니다.",
                "권리 행사는 이용자의 법정대리인이나 위임을 받은 대리인을 통해서도 할 수 있습니다."
            ])
        }
    }

    var article7: some View {
        articleSection(title: "제7조. 개인정보의 파기") {
            numberedItems([
                "회사는 보유 기간이 지나거나 처리 목적이 달성된 개인정보를 지체 없이 파기합니다.",
                "전자적 파일은 복구할 수 없는 방법으로 삭제하며, 종이 문서는 분쇄하거나 소각합니다."
            ])
        }
    }

    var article8: some View {
        articleSection(title: "제8조. 만 14세 미만 아동의 개인정보") {
            bodyText("서비스는 만 14세 이상만 이용할 수 있으며, 회사는 만 14세 미만 아동의 개인정보를 수집하지 않습니다. 만 14세 미만 아동이 가입한 사실이 확인되면 해당 계정과 개인정보를 지체 없이 삭제합니다.")
        }
    }

    var article9: some View {
        articleSection(title: "제9조. 민감한 내용의 공개 가능성 및 비공개 방법") {
            numberedItems([
                "커뮤니티에 작성한 게시물과 댓글은 닉네임과 함께 다른 회원에게 공개됩니다. 건강이나 심리 상태 등 민감한 내용을 작성하는 경우 다른 회원이 볼 수 있으므로 유의하시기 바랍니다.",
                "공개를 원하지 않는 경우 해당 내용을 작성하지 않거나, 작성한 게시물·댓글을 수정 또는 삭제할 수 있습니다.",
                "감정기록, 심리 자가진단 결과, 추모편지, 추억앨범은 다른 회원에게 공개되지 않습니다."
            ])
        }
    }

    var article10: some View {
        articleSection(title: "제10조. 개인정보의 안전성 확보조치") {
            bulletItems([
                "관리적 조치: 개인정보를 다루는 인원의 최소화, 접근 권한 관리, 취급 시 유의사항 공유",
                "기술적 조치: 전송 구간 암호화(HTTPS), Firebase 보안 규칙을 통한 접근 통제, 감정기록·심리 자가진단 결과 등 심리 관련 정보의 기기 내 저장(회사 서버 미저장)"
            ])
        }
    }

    var article11: some View {
        articleSection(title: "제11조. 자동 수집 장치의 설치·운영") {
            bodyText("서비스는 모바일 앱으로 제공되며 쿠키를 사용하지 않습니다. 회사는 이용 행태 분석 도구를 사용하지 않고 맞춤형 광고를 하지 않습니다. 다만 로그인과 서버 접속 과정에서 접속 일시, IP 주소 등 접속 기록이 Firebase에 자동으로 생성될 수 있습니다.")
        }
    }

    var article12: some View {
        articleSection(title: "제12조. 개인정보 보호책임자") {
            bodyText("회사는 개인정보 처리에 관한 업무를 총괄하고, 관련 문의·불만 처리 및 피해 구제를 위해 아래와 같이 개인정보 보호책임자를 지정합니다.")
            bulletItems([
                "성명: 임소은",
                "직책: 개발 리드",
                "연락처: dlathdms1206@gmail.com"
            ])
        }
    }

    var article13: some View {
        articleSection(title: "제13조. 권익침해 구제 방법") {
            bodyText("이용자는 개인정보 침해로 인한 구제를 받기 위해 아래 기관에 분쟁 해결이나 상담을 신청할 수 있습니다.")
            bulletItems([
                "개인정보 분쟁조정위원회: 1833-6972 (www.kopico.go.kr)",
                "개인정보침해신고센터: 118 (privacy.kisa.or.kr)",
                "대검찰청: 1301 (www.spo.go.kr)",
                "경찰청: 182 (ecrm.police.go.kr/minwon/main)"
            ])
        }
    }

    var article14: some View {
        articleSection(title: "제14조. 개인정보처리방침의 변경") {
            numberedItems([
                "본 방침은 시행일부터 적용되며, 내용을 변경하는 경우 시행 7일 전부터 앱 내 개인정보처리방침 화면을 통해 변경 내용을 알립니다.",
                "수집 항목의 추가, 국외 이전의 변경 등 이용자의 권리에 중대한 영향을 미치는 변경은 시행 30일 전부터 알립니다."
            ])
        }
    }

    var effectiveDate: some View {
        Text("본 방침은 2026년 10월 7일부터 적용됩니다.")
            .typography(.body2R1)
            .foregroundStyle(.gray70)
            .padding(.top, 8)
    }
}

// MARK: - Helpers

private extension PrivacyPolicyView {

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

    func delegateTable(title: String, rows: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .typography(.body2Accent)
                .foregroundStyle(.gray80)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.gray10)

            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                VStack(spacing: 0) {
                    HStack(alignment: .top, spacing: 0) {
                        Text(row.0)
                            .typography(.body3R)
                            .foregroundStyle(.gray60)
                            .frame(width: 110, alignment: .leading)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                        Rectangle()
                            .fill(.gray20)
                            .frame(width: 1)
                        Text(row.1)
                            .typography(.body3R)
                            .foregroundStyle(.gray70)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    if index < rows.count - 1 {
                        Rectangle()
                            .fill(.gray20)
                            .frame(height: 1)
                    }
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.gray20, lineWidth: 1)
        )
        .cornerRadius(8, corners: .allCorners)
    }
}
