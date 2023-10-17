//
//  Utils.swift
//  ToDoApp
//
//  Created by Vineeth Gopinathan on 14/10/23.
//

import UIKit

class Utils {
    
    //MARK: - Timestamp conversion
    static func getCurrentTimeStamp() -> String {
        
        let timestamp = Date()
        print(timestamp)
        
        let dateFormatter = DateFormatter()
        //specify the date Format
        dateFormatter.dateFormat = "dd-MM-yyy hh:mm:ss a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        
        let resultDate = dateFormatter.string(from: timestamp)
        print(resultDate)
        return resultDate
        
    }

}
