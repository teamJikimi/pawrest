//
//  WeekdayEmotionBarChart.swift
//  pawrest
//
//  Created by 소은 on 6/4/26.
//

import SwiftUI
import Charts

struct WeekdayEmotionBarChart: View {
    let entries: [WeekdayEmotionData.WeekdayEntry]
    private let chartColor = Color(uiColor: .secondaryLight)

    var body: some View {
        Chart {
            barMarks
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
            AxisMarks(values: entries.map(\.label)) { value in
                AxisValueLabel {
                    if let label = value.as(String.self) {
                        Text(label)
                            .typography(.date)
                            .foregroundStyle(.gray50)
                    }
                }
            }
        }
        .frame(height: 227)
    }
}

private extension WeekdayEmotionBarChart {
    @ChartContentBuilder
    var barMarks: some ChartContent {
        ForEach(entries) { entry in
            BarMark(
                x: .value("요일", entry.label),
                y: .value("감정", entry.level?.rawValue ?? 0),
                width: .fixed(24)
            )
            .foregroundStyle(chartColor)
            .cornerRadius(6)
        }
    }
}
