//
//  ApiHelper.swift
//  SmartHealth
//
//  Created by laoniu on 2017/10/24.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import Foundation
import Alamofire

class ApiHelper {
    class func getDefaultHeader() -> [String:String]{
        let header: HTTPHeaders = [
            Constants.ContentType: Constants.ContentTypeJson,
            Constants.Accept: Constants.ContentTypeJson
        ]
        return header
    }
}
