
//
//  EmotionLineChart.swift
//  pawrest
//
//  Created by 소은 on 6/1/26.
//

import SwiftUI
import Charts

//struct EmotionLineChart: View {
//    let entries: [WeeklyEmotionChartData.DailyEmotionEntry]
//
//    private let chartColor = Color(.pawPrimary)
//
//    var body: some View {
//        Chart {
//            ForEach(entries) { entry in
//                // X축 자리 확보용 (투명)
//                PointMark(
//                    x: .value("요일", entry.weekdayLabel),
//                    y: .value("감정", 0)
//                )
//                .foregroundStyle(.clear)
//                .symbolSize(0)
//
//                if let level = entry.level {
//                    LineMark(
//                        x: .value("요일", entry.weekdayLabel),
//                        y: .value("감정", level.rawValue)
//                    )
//                    .foregroundStyle(chartColor)
//                    .interpolationMethod(.linear)
//                    .lineStyle(StrokeStyle(lineWidth: 1))
//
//                    PointMark(
//                        x: .value("요일", entry.weekdayLabel),
//                        y: .value("감정", level.rawValue)
//                    )
//                    .foregroundStyle(chartColor)
//                    .symbolSize(40)
//                }
//            }
//        }
//        .chartYScale(domain: 0...4)
//        .chartYAxis {
//            AxisMarks(preset: .aligned, position: .leading, values: [0, 1, 2, 3, 4]) { value in
//                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))
//                    .foregroundStyle(Color(.systemGray4))
//                AxisValueLabel(anchor: .trailing) {
//                    if let intVal = value.as(Int.self),
//                       let level = EmotionLevel(rawValue: intVal) {
//                        Text(level.label)
//                            .font(.system(size: 10))
//                            .foregroundColor(.secondary)
//                    }
//                }
//            }
//        }
//        .chartXAxis {
//            AxisMarks(values: entries.map(\.weekdayLabel)) { _ in
//                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))
//                    .foregroundStyle(Color(.systemGray4))
//                AxisValueLabel()
//                    .font(.system(size: 11))
//            }
//        }
//        .frame(height: 227)
//    }
//}


struct EmotionLineChart: View {
    let entries: [WeeklyEmotionChartData.DailyEmotionEntry]

    private let chartColor = Color(.pawPrimary)

    private var segments: [[WeeklyEmotionChartData.DailyEmotionEntry]] {
        var result: [[WeeklyEmotionChartData.DailyEmotionEntry]] = []
        var current: [WeeklyEmotionChartData.DailyEmotionEntry] = []
        for entry in entries {
            if entry.level != nil {
                current.append(entry)
            } else {
                if !current.isEmpty {
                    result.append(current)
                    current = []
                }
            }
        }
        if !current.isEmpty { result.append(current) }
        return result
    }

    var body: some View {
        Chart {
            placeholderMarks
            segmentMarks
        }
        .chartYScale(domain: 0...4)
        .chartYAxis {
            AxisMarks(preset: .aligned, position: .leading, values: [0, 1, 2, 3, 4]) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))
                    .foregroundStyle(Color(.systemGray4))
                AxisValueLabel(anchor: .trailing) {
                    if let intVal = value.as(Int.self),
                       let level = EmotionLevel(rawValue: intVal) {
                        Text(level.label)
                            .typography(.date)
                            .foregroundStyle(.gray50)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: entries.map(\.weekdayLabel)) { _ in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))
                    .foregroundStyle(.gray30)
                AxisValueLabel()
                    .foregroundStyle(.gray50)
            }
        }
        .frame(height: 227)
    }
}

private extension EmotionLineChart {
    @ChartContentBuilder
    var placeholderMarks: some ChartContent {
        ForEach(entries) { entry in
            PointMark(
                x: .value("요일", entry.weekdayLabel),
                y: .value("감정", 0)
            )
            .foregroundStyle(.clear)
            .symbolSize(0)
        }
    }
    
    @ChartContentBuilder
    var segmentMarks: some ChartContent {
        ForEach(Array(segments.enumerated()), id: \.offset) { index, segment in
            ForEach(segment) { entry in
                BarMark(
                    x: .value("요일", entry.weekdayLabel),
                    y: .value("감정", entry.level!.rawValue)
                )
                .foregroundStyle(chartColor.opacity(0.15))
                .cornerRadius(4)
                
                LineMark(
                    x: .value("요일", entry.weekdayLabel),
                    y: .value("감정", entry.level!.rawValue),
                    series: .value("구간", index)
                )
                .foregroundStyle(chartColor)
                .interpolationMethod(.linear)
                .lineStyle(StrokeStyle(lineWidth: 1))
                
                PointMark(
                    x: .value("요일", entry.weekdayLabel),
                    y: .value("감정", entry.level!.rawValue)
                )
                .foregroundStyle(chartColor)
                .symbol(Circle())
                .symbolSize(CGSize(width: 6, height: 6))
            }
        }
    }
}
