//
//  DateTime.swift
//  Unlost
//
//  Created by Mounir Raki on 02.08.22.
//

import Foundation
import Firebase

//TODO: CHECK IF NANOSECONDS ARE NECESSARY (SHOULD NOT BE THE CASE)
class DateTime: Equatable, Comparable {
    static func < (lhs: DateTime, rhs: DateTime) -> Bool {
        return lhs.seconds < rhs.seconds
    }
    
    static func == (lhs: DateTime, rhs: DateTime) -> Bool {
        return lhs.seconds == rhs.seconds
    }
    
    let seconds: Int64
    
    init(seconds: Int64){
        self.seconds = seconds
    }
    
    static func fromAppleDate(from: Date) -> DateTime {
        return DateTime(seconds: Int64(from.timeIntervalSince1970))
    }
    
    static func fromFIRTimestamp(from: Timestamp) -> DateTime {
        return DateTime(seconds: from.seconds)
    }
    
    func toAppleDate() -> Date {
        return Date(timeIntervalSince1970: Double(self.seconds))
    }
    
    func toFIRTimestamp() -> Timestamp {
        return Timestamp(seconds: self.seconds, nanoseconds: 0)
    }
}
