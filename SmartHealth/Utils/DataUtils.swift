//
//  DataUtils.swift
//  SmartHealth
//
//  Created by laoniu on 2017/10/23.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import UIKit
class DateUtils {
    class func dateFromString(string: String, format: String) -> Date {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar.init(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.date(from: string)!
    }
    
    class func stringFromDate(date: Date, format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar.init(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
