//
//  Utils.swift
//  SmartHealth
//
//  Created by laoniu on 2017/10/25.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import Foundation
class Utils :NSObject{
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
    
    class func getFileMangetr() -> URL {
        let url = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        return url
    }
}
