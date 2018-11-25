//
//  Helper.swift
//  MessageApp
//
//  Created by Huynh Huy on 11/17/18.
//  Copyright © 2018 Huynh Huy. All rights reserved.
//

import Foundation

class Helper: NSObject {
    
    static func getDescription(of date: NSDate) -> String {
        let date = date as Date
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        if calendar.compare(date, to: Date(), toGranularity: .day) == .orderedSame {
            dateFormatter.dateFormat = "hh:mm"
        } else {
            if calendar.compare(date, to: Date(), toGranularity: .weekOfYear) == .orderedSame {
                // Show Yesterday
                if let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()), calendar.compare(yesterday, to: date, toGranularity: .day) == .orderedSame {
                    return "Yesterday"
                }
                dateFormatter.dateFormat = "EEEE"
            } else {
                dateFormatter.dateFormat = "MM/dd/YY"
            }
        }
        return dateFormatter.string(from: date)
    }
    
}
