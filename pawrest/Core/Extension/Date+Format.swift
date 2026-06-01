//
//  Date+Format.swift
//  pawrest
//
//  Created by 소은 on 6/1/26.
//

import Foundation

extension Date {
    var formattedRelative: String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")

        if calendar.isDate(self, equalTo: .now, toGranularity: .year) {
            formatter.dateFormat = "MM.dd"
        } else {
            formatter.dateFormat = "yy.MM.dd"
        }
        return formatter.string(from: self)
    }
}
