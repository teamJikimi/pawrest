//
//  TimeEmotionBarChart.swift
//  pawrest
//
//  Created by 소은 on 6/4/26.
//

import SwiftUI
import Charts

struct TimeEmotionBarChart: View {
    let slots: [TimeSlotEmotion]
    private let chartColor = Color(uiColor: .accentLight)

    var body: some View {
        Chart {
            barMarks
        }
        .chartYScale(domain: 0...4)
        .chartYAxis {
            AxisMarks(preset: .aligned, position: .leading, values: [0, 1, 2, 3, 4]) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))
                    .foregroundStyle(.gray30)
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
            AxisMarks(values: slots.map(\.timeSlot.label)) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3, 3]))
                    .foregroundStyle(.gray30)
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

private extension TimeEmotionBarChart {
    @ChartContentBuilder
    func barMark(for slot: TimeSlotEmotion) -> some ChartContent {
        BarMark(
            x: .value("시간대", slot.timeSlot.label),
            y: .value("감정", slot.level?.rawValue ?? 0),
            width: .fixed(32)
        )
        .foregroundStyle(chartColor)
        .cornerRadius(8)
    }

    @ChartContentBuilder
    var barMarks: some ChartContent {
        ForEach(slots) { slot in
            barMark(for: slot)
        }
    }
}
