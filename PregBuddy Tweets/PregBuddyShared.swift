//
//  PregBuddyShared.swift
//  PregBuddy Tweets
//
//  Created by CBH iOS on 09/03/18.
//  Copyright © 2018 MM iOS. All rights reserved.
//

import UIKit

class PregBuddyShared: NSObject {
    
    func convertdateStringToDate(_ dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        //Fri Jan 16 20:32:55 +0000 2009
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss zzzz yyyy"
        let date = dateFormatter.date(from: dateString)!
        return date
    }
    
    func getTimeAgoFromDate(_ dateString: String) -> String {
        let date = convertdateStringToDate(dateString)
    
        let interval = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date, to: Date())
        
        if let year = interval.year, year > 0 {
            return year == 1 ? "\(year)" + " " + "year" :
                "\(year)" + " " + "years"
        } else if let month = interval.month, month > 0 {
            return month == 1 ? "\(month)" + " " + "mon" :
                "\(month)" + " " + "mon"
        } else if let day = interval.day, day > 0 {
            return day == 1 ? "\(day)" + " " + "day" :
                "\(day)" + " " + "days"
        } else if let hour = interval.hour, hour > 0 {
            return hour == 1 ? "\(hour)" + " " + "hour" :
                "\(hour)" + " " + "hour"
        } else if let minute = interval.minute, minute > 0 {
            return minute == 1 ? "\(minute)" + " " + "min" :
                "\(minute)" + " " + "min"
        } else if let second = interval.second, second > 0 {
            return second == 1 ? "\(second)" + " " + "sec" :
                "\(second)" + " " + "sec"
        } else {
            return "Just now"
        }
        
    }

    func convertStringFromJSON(obj: Any) -> String {
        do {
            let data1 =  try JSONSerialization.data(withJSONObject: obj, options: JSONSerialization.WritingOptions.prettyPrinted)
            let convertedString = String(data: data1, encoding: String.Encoding.utf8)
            return convertedString!
        } catch let myJSONError {
            print(myJSONError)
        }
        return ""
    }
    func convertJSONFromString(obj: String) -> Any {
        if let data = obj.data(using: String.Encoding.utf8) {
            do {
                let dictonary = try JSONSerialization.jsonObject(with: data, options: []) as Any
                return dictonary
            }
            catch let error as NSError {
                print(error)
            }
        }
        return ""
    }

}
