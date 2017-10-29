//
//  Utils.swift
//  SmartHealth
//
//  Created by laoniu on 2017/10/25.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import Foundation
class Utils {
    class func printMsg(msg :String){
        if(Constants.Debug){
            print(msg)
        }
    }
    
    class func isEmpty(string : String?) -> Bool {
        guard let theString = string else {
            return true
        }
        return theString.isEmpty
    }
}
