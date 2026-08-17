//
//  AIService.swift
//  pawrest
//
//  Created by 소은 on 8/16/26.
//

import Foundation

final class AIService {
    static let shared = AIService()

    private let apiKey = Secrets.geminiAPIKey
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash:generateContent"

    private init() {}

    // MARK: - 주간 AI 감정 요약 (2문장)
    func generateWeeklySummary(snapshots: [EmotionSnapshot]) async throws -> String {
        guard !snapshots.isEmpty else { return "이번 주 감정 기록이 없어요." }
        let prompt = """
        아래는 사용자의 최근 감정 기록이에요.
        펫로스 증후군을 겪고 있는 사람을 위해 이번 주 감정을 따뜻하게 2문장으로만 요약해주세요.
        예시: "이번 주는 전반적으로 안정적인 감정을 유지했어요. 힘든 순간도 있었지만 잘 버텨냈어요."

        \(buildEmotionText(snapshots))
        """
        return try await request(prompt: prompt)
    }

    // MARK: - 배너 한줄 요약 (15자 이내)
    func generateOneLiner(snapshots: [EmotionSnapshot]) async throws -> String {
        guard !snapshots.isEmpty else { return "기록이 쌓이면 변화를 확인할 수 있어요" }
        let prompt = """
        아래는 사용자의 최근 감정 기록이에요.
        15자 이내 한 문장으로만 요약해주세요. 문장만 작성하세요.

        \(buildEmotionText(snapshots))
        """
        return try await request(prompt: prompt)
    }

    // MARK: - 배너 제목 (10자 이내)
    func generateTitle(snapshots: [EmotionSnapshot]) async throws -> String {
        guard !snapshots.isEmpty else { return "이번 주 감정 기록을 남겨보세요" }
        let prompt = """
        아래는 사용자의 최근 감정 기록이에요.
        이번 주 감정을 표현하는 제목을 10자 이내로만 작성하세요. 제목만 작성하세요.

        \(buildEmotionText(snapshots))
        """
        return try await request(prompt: prompt)
    }

    // MARK: - 일별 그래프 인사이트
    func generateWeeklyInsight(entries: [(date: String, level: String?)]) async throws -> String? {
        guard entries.contains(where: { $0.level != nil }) else { return nil }
        let chartText = entries.map { "\($0.date): \($0.level ?? "기록없음")" }.joined(separator: "\n")
        let prompt = """
        아래는 이번 주 날짜별 감정 데이터예요.
        어떤 날에 감정이 높고 낮은지 2문장으로 따뜻하게 분석해주세요.
        예시: "화요일에 감정이 가장 높은 편이고, 수요일에 유독 낮아지는 경향이 있어요. 수요일을 조금 더 챙겨보면 좋을 것 같아요."

        \(chartText)
        """
        return try await request(prompt: prompt)
    }

    // MARK: - 요일별 그래프 인사이트
    func generateWeekdayInsight(entries: [(weekday: String, level: String?)]) async throws -> String? {
        guard entries.contains(where: { $0.level != nil }) else { return nil }
        let chartText = entries.map { "\($0.weekday): \($0.level ?? "기록없음")" }.joined(separator: "\n")
        let prompt = """
        아래는 요일별 평균 감정 데이터예요.
        어떤 요일에 감정이 높고 낮은지 2문장으로 따뜻하게 분석해주세요.
        예시: "화요일에 감정이 가장 높은 편이고, 수요일에 유독 낮아지는 경향이 있어요. 수요일을 조금 더 챙겨보면 좋을 것 같아요."

        \(chartText)
        """
        return try await request(prompt: prompt)
    }

    // MARK: - 시간대별 그래프 인사이트
    func generateTimeInsight(entries: [(timeSlot: String, level: String?)]) async throws -> String? {
        guard entries.contains(where: { $0.level != nil }) else { return nil }
        let chartText = entries.map { "\($0.timeSlot): \($0.level ?? "기록없음")" }.joined(separator: "\n")
        let prompt = """
        아래는 오늘 시간대별 감정 데이터예요.
        어떤 시간대에 감정이 높고 낮은지 2문장으로 따뜻하게 분석해주세요.
        예시: "아침에 감정이 가장 안정적이고, 저녁에 조금 낮아지는 편이에요. 저녁 시간에 가벼운 산책이 도움이 될 수 있어요."

        \(chartText)
        """
        return try await request(prompt: prompt)
    }

    // MARK: - 감정 텍스트 변환
    private func buildEmotionText(_ snapshots: [EmotionSnapshot]) -> String {
        snapshots.map { snapshot in
            let dateStr = snapshot.recordedAt.formatted(date: .abbreviated, time: .omitted)
            let memo = snapshot.memo.isEmpty ? "" : " - \(snapshot.memo)"
            return "\(dateStr): \(snapshot.emotionLabel)\(memo)"
        }.joined(separator: "\n")
    }

    // MARK: - Gemini API 요청
    private func request(prompt: String) async throws -> String {
        let body: [String: Any] = [
            "contents": [
                ["parts": [["text": prompt]]]
            ]
        ]

        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse {
            print("[AIService] Status: \(http.statusCode)")
        }
        if let raw = String(data: data, encoding: .utf8) {
            print("[AIService] Response: \(raw.prefix(300))")
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
