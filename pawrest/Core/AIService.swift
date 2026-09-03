//
//  AIService.swift
//  pawrest
//
//  Created by 소은 on 8/16/26.
//

import Foundation

struct AIReportResult: Equatable {
    let bannerTitle: String
    let bannerSummary: String
    let weeklySummary: String
    let dailyInsight: String?
}

final class AIService {
    static let shared = AIService()

    private let apiKey = Secrets.geminiAPIKey
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash:generateContent"

    private init() {}

    // MARK: - 통합 리포트 생성
    func generateReport(snapshots: [EmotionSnapshot], weeklyEntries: [(date: String, level: String?)], assessmentRecords: [AssessmentRecord] = []) async throws -> AIReportResult {
        let count = snapshots.count

        if count == 0 {
            return AIReportResult(
                bannerTitle: "이번 주 기록을 남겨보세요",
                bannerSummary: "기록이 쌓이면 변화를 확인할 수 있어요",
                weeklySummary: "이번 주는 기록된 감정이 없어요.\n짧게라도 남겨두면 다음 주엔\n마음의 흐름을 함께 살펴볼 수 있어요.",
                dailyInsight: nil
            )
        }

        let emotionText = buildEmotionText(snapshots)
        let chartText = weeklyEntries.map { "\($0.date): \($0.level ?? "기록없음")" }.joined(separator: "\n")
        let assessmentText = buildAssessmentText(assessmentRecords)

        let prompt: String

        if count <= 2 {
            prompt = """
            [역할]
            너는 반려동물과 사별한 사용자의 감정 기록을 정리해 주는 주간 리포트 작성자야.

            [상황]
            이번 주 기록이 \(count)건뿐이야.
            분석하기에 데이터가 부족한 상태이니, 추세나 패턴을 말하려 하지 마. 기록된 것만 담백하게 짚어주면 돼.

            [입력 데이터]
            기록 건수: \(count)건 / 7일
            날짜별 감정:
            \(chartText)
            감정 척도: 편안(5) 안정(4) 보통(3) 답답(2) 우울(1)
            \(assessmentText.isEmpty ? "" : "\n[자가진단 결과]\n\(assessmentText)")

            [절대 규칙]
            1. 입력에 없는 감정, 사건, 상태를 절대 만들어내지 마.
            2. 기록이 없는 날의 감정을 단정하거나 추정하지 마.
               허용: "평온한 하루였길 바라요" ← 바람 표현은 dailyInsight에만, 전체 1회만.
               weeklySummary에는 쓰지 마.
            3. 추세, 흐름, 변화, 패턴을 말하지 마.
            4. 상반된 감정을 한 문장에 병렬하지 마.
            5. 추측형 위로 금지: "~하셨을 거예요", "~였을 텐데"
            6. 진단·단정 표현 금지: 우울증, 증후군, 위험, 심각, 걱정돼요
            7. 지시·훈계 금지: ~해야 해요, ~하세요, 기록해보세요
            8. 반려동물의 죽음을 직접 언급하지 마.
            9. 이모지, 느낌표, 감탄사 쓰지 마.
            10. 분량을 채우려고 문장을 늘리지 마.

            [톤]
            담백하고 조용한 존댓말 '~해요'체.
            기록해준 그 하루를 존중하는 쪽으로.

            [출력]
            아래 JSON만 출력. 다른 말 붙이지 마.
            {
              "bannerTitle": "10자 이내. 기록된 감정을 표현하는 제목.",
              "bannerSummary": "20자 이내. 기록된 감정을 한 문장으로. 추세 표현 쓰지 마.",
              "weeklySummary": "2문장. 각 15어절 이내. 1문장: 언제 어떤 감정인지. 2문장: 짧은 인정.",
              "dailyInsight": "1~2문장. 각 13어절 이내. 기록된 날 감정 짚기 + 바람 표현 1회(생략 가능)."
            }
            """
        } else {
            prompt = """
            [역할]
            너는 반려동물과 사별한 사용자의 감정 기록을 정리해 주는 주간 리포트 작성자야.

            [입력 데이터]
            기록 건수: \(count)건 / 7일
            날짜별 감정:
            \(chartText)
            상세 기록:
            \(emotionText)
            감정 척도: 편안(5) 안정(4) 보통(3) 답답(2) 우울(1)
            \(assessmentText.isEmpty ? "" : "\n[자가진단 결과]\n\(assessmentText)")

            [절대 규칙]
            1. 입력에 없는 감정, 사건, 상태를 절대 만들어내지 마.
            2. 기록이 없는 날의 감정을 단정하거나 추정하지 마.
               허용: "평온한 하루였길 바라요" ← 바람 표현은 dailyInsight에만, 전체 1회만.
               weeklySummary에는 쓰지 마.
            3. 상반된 감정을 한 제목/한 문장에 병렬하지 마.
               금지: "평온함 속 답답함", "안정과 답답함이 교차해요"
            4. 추측형 위로 금지: "~하셨을 거예요", "~였을 텐데"
            5. 진단·단정 표현 금지: 우울증, 증후군, 위험, 심각, 걱정돼요
            6. 지시·훈계 금지: ~해야 해요, ~하세요 → ~해도 좋아요 정도까지만
            7. 반려동물의 죽음을 직접 언급하지 마.
            8. 이모지, 느낌표, 감탄사 쓰지 마.

            [톤]
            담백하고 조용한 존댓말 '~해요'체.
            과장된 위로보다 사실을 차분히 짚어주는 쪽.

            [출력]
            아래 JSON만 출력. 다른 말 붙이지 마.
            {
              "bannerTitle": "10자 이내. 이번 주 감정을 표현하는 제목.",
              "bannerSummary": "20자 이내. 이번 주 흐름을 한 문장으로.",
              "weeklySummary": "3문장. 각 15어절 이내. 일별/시간대별/요일별 통합 요약.",
              "dailyInsight": "2문장. 각 13어절 이내. 높/낮은 날 짚고 한마디 덧붙여."
            }
            """
        }

        let raw = try await request(prompt: prompt)
        return parseReportJSON(raw, count: count)
    }

    // MARK: - 요일별/시간대별 인사이트 (별도)
    func generateWeekdayInsight(entries: [(weekday: String, level: String?)]) async throws -> String? {
        guard entries.contains(where: { $0.level != nil }) else { return nil }
        let chartText = entries.map { "\($0.weekday): \($0.level ?? "기록없음")" }.joined(separator: "\n")
        let prompt = """
        아래는 요일별 평균 감정 데이터예요.
        어떤 요일에 감정이 높고 낮은지 2문장으로 분석해주세요.
        각 문장 13어절 이내. 이모지, 느낌표 쓰지 마. JSON 없이 텍스트만.
        예시: "화요일에 감정이 가장 편안했고, 수요일엔 조금 낮아졌어요. 목요일부터는 다시 안정을 찾아가고 있어요."

        \(chartText)
        """
        let result = try await request(prompt: prompt)
        return result.isEmpty ? nil : result
    }

    func generateTimeInsight(entries: [(timeSlot: String, level: String?)]) async throws -> String? {
        guard entries.contains(where: { $0.level != nil }) else { return nil }
        let chartText = entries.map { "\($0.timeSlot): \($0.level ?? "기록없음")" }.joined(separator: "\n")
        let prompt = """
        아래는 오늘 시간대별 감정 데이터예요.
        어떤 시간대에 감정이 높고 낮은지 2문장으로 분석해주세요.
        각 문장 13어절 이내. 이모지, 느낌표 쓰지 마. JSON 없이 텍스트만.
        예시: "아침에 감정이 가장 안정적이었고, 저녁에 조금 낮아지는 편이에요. 저녁 시간을 가볍게 보내도 좋아요."

        \(chartText)
        """
        let result = try await request(prompt: prompt)
        return result.isEmpty ? nil : result
    }

    // MARK: - Private

    private func buildEmotionText(_ snapshots: [EmotionSnapshot]) -> String {
        snapshots.map { snapshot in
            let dateStr = snapshot.recordedAt.formatted(date: .abbreviated, time: .omitted)
            let memo = snapshot.memo.isEmpty ? "" : " - \(snapshot.memo)"
            return "\(dateStr): \(snapshot.emotionLabel)\(memo)"
        }.joined(separator: "\n")
    }

    private func buildAssessmentText(_ records: [AssessmentRecord]) -> String {
        guard !records.isEmpty else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return records.map { record in
            let typeName = record.type?.title ?? record.typeRawValue
            let label = record.type?.resultLabel(for: record.totalScore) ?? ""
            let dateStr = formatter.string(from: record.date)
            return "\(dateStr) \(typeName): \(record.totalScore)점 (\(label))"
        }.joined(separator: "\n")
    }

    private func parseReportJSON(_ raw: String, count: Int) -> AIReportResult {
        guard let data = raw.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            guard let startIdx = raw.firstIndex(of: "{"),
                  let endIdx = raw.lastIndex(of: "}") else {
                print("[AIService] JSON 블록 없음: \(raw)")
                return fallbackResult(count: count)
            }
            let jsonString = String(raw[startIdx...endIdx])
            guard let data2 = jsonString.data(using: .utf8),
                  let json2 = try? JSONSerialization.jsonObject(with: data2) as? [String: Any] else {
                print("[AIService] JSON 파싱 실패: \(raw)")
                return fallbackResult(count: count)
            }
            return AIReportResult(
                bannerTitle: (json2["bannerTitle"] as? String) ?? fallbackResult(count: count).bannerTitle,
                bannerSummary: (json2["bannerSummary"] as? String) ?? fallbackResult(count: count).bannerSummary,
                weeklySummary: (json2["weeklySummary"] as? String) ?? fallbackResult(count: count).weeklySummary,
                dailyInsight: json2["dailyInsight"] as? String
            )
        }
        return AIReportResult(
            bannerTitle: (json["bannerTitle"] as? String) ?? fallbackResult(count: count).bannerTitle,
            bannerSummary: (json["bannerSummary"] as? String) ?? fallbackResult(count: count).bannerSummary,
            weeklySummary: (json["weeklySummary"] as? String) ?? fallbackResult(count: count).weeklySummary,
            dailyInsight: json["dailyInsight"] as? String
        )
    }

    private func fallbackResult(count: Int) -> AIReportResult {
        if count == 0 {
            return AIReportResult(
                bannerTitle: "이번 주 기록을 남겨보세요",
                bannerSummary: "기록이 쌓이면 변화를 확인할 수 있어요",
                weeklySummary: "이번 주는 기록된 감정이 없어요.\n짧게라도 남겨두면 다음 주엔\n마음의 흐름을 함께 살펴볼 수 있어요.",
                dailyInsight: nil
            )
        }
        return AIReportResult(
            bannerTitle: "이번 주 기록을 남겨보세요",
            bannerSummary: "기록이 쌓이면 변화를 확인할 수 있어요",
            weeklySummary: "",
            dailyInsight: nil
        )
    }

    // MARK: - Gemini API 요청
    private func request(prompt: String) async throws -> String {
        let body: [String: Any] = [
            "contents": [["parts": [["text": prompt]]]]
        ]

        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
            throw URLError(.badURL)
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: req)

        if let http = response as? HTTPURLResponse {
            print("[AIService] Status: \(http.statusCode)")
        }
        if let raw = String(data: data, encoding: .utf8) {
            print("[AIService] Response: \(raw.prefix(500))")
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return "" }
        if let error = json["error"] as? [String: Any] {
            print("[AIService] API Error: \(error)")
            return ""
        }

        guard let candidates = json["candidates"] as? [[String: Any]],
              let content = candidates.first?["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let text = parts.first?["text"] as? String else { return "" }

        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
