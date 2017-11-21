//
//  SHHeartRateDataModel.swift
//  SmartHealth
//
//  Created by laoniu on 2017/10/29.
//  Copyright © 2017年 laoniu. All rights reserved.
//
import Foundation
import ObjectMapper
class SHHeartRateDataModel: NSObject, Mappable {
    var msg: String?
    var success: Bool
    var detailMessage: String?
    var statusCode: String?
    var resultDataType: String?
    var resultData: String?
    var uploadId: String?
    var def1: String?
    var def2: String?
    var def3: String?
    var calorie: String?
    var heart: String?
    required init(map: Map) {
        self.success = false
    }
    
    public override init(){
        self.success = false
    }
    
    func mapping(map: Map) {
        msg <- map["msg"]
        success <- map["success"]
        detailMessage <- map["detailMessage"]
        statusCode <- map["statusCode"]
        resultDataType <- map["resultDataType"]
        resultData <- map["resultData"]
        uploadId <- map["uploadId"]
        def1 <- map["def1"]
        def2 <- map["def2"]
        def3 <- map["def3"]
        calorie <- map["calorie"]
        heart <- map["heart"]
    }
}
