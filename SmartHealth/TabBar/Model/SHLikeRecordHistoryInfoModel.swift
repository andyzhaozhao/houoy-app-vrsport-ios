//
//  SHLikeRecordHistoryInfoModel.swift
//  SmartHealth
//
//  Created by laoniu on 2017/10/29.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import Foundation
import ObjectMapper
class SHLikeRecordHistoryInfoModel: Mappable {
    var msg: String?
    var success: Bool = false
    var detailMessage: String?
    var statusCode: String?
    var resultDataType: String?
    var resultData: [SHLikeRecordHistoryListModel] = []
    var uploadId: String?
    var def1: String?
    var def2: String?
    var def3: String?
    var def4: String?
    var def5: String?
    var start: Int = 0
    var length: Int?
    var orderColumnName: String?
    var orderDir: String?
    var total: String?
    
    required init(map: Map) {
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
        def4 <- map["def4"]
        def5 <- map["def5"]
        start <- map["start"]
        length <- map["length"]
        orderColumnName <- map["orderColumnName"]
        orderDir <- map["orderDir"]
        total <- map["total"]
    }
}

class SHLikeRecordHistoryListModel: Mappable {
    var memo: String?
    var def1: String?
    var def2: String?
    var def3: String?
    var def4: String?
    var def5: String?
    var be_std: String?
    var ts: String?
    var dr: String?
    var start: String?
    var length: String?
    var orderColumnName: String?
    var orderDir: String?
    var pk_record_sport: String?
    var record_sport_code: String?
    var record_sport_name: String?
    var pk_person: String?
    var person_name: String?
    var pk_place: String?
    var place_name: String?
    var pk_video: String?
    var video_name: String?
    var time_start: String?
    var time_end: String?
    var time_length: String?
    var heart_rate: String?
    var heart_rate_max: String?
    var indicator_time_start: String?
    var indicator_time_end: String?
    var indicator_heart_rate_min: String?
    var indicator_heart_rate_max: String?
    var indicator_heart_rate_max_min: String?
    var indicator_heart_rate_max_max: String?
    var indicator_calorie_min: String?
    var indicator_calorie_max: String?
    var pkvalue: String?
    var tableName: String?
    var pkfield: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        memo <- map["memo"]
        def1 <- map["def1"]
        def2 <- map["def2"]
        def3 <- map["def3"]
        def4 <- map["def4"]
        def5 <- map["def5"]
        be_std <- map["be_std"]
        ts <- map["ts"]
        dr <- map["dr"]
        start <- map["start"]
        length <- map["length"]
        orderColumnName <- map["orderColumnName"]
        orderDir <- map["orderDir"]
        pk_record_sport <- map["pk_record_sport"]
        record_sport_code <- map["record_sport_code"]
        record_sport_name <- map["record_sport_name"]
        pk_person <- map["pk_person"]
        person_name <- map["person_name"]
        pk_place <- map["pk_place"]
        place_name <- map["place_name"]
        pk_video <- map["pk_video"]
        video_name <- map["video_name"]
        time_start <- map["time_start"]
        time_end <- map["time_end"]
        time_length <- map["time_length"]
        heart_rate <- map["heart_rate"]
        heart_rate_max <- map["heart_rate_max"]
        indicator_time_start <- map["indicator_time_start"]
        indicator_time_end <- map["indicator_time_end"]
        indicator_heart_rate_min <- map["indicator_heart_rate_min"]
        indicator_heart_rate_max <- map["indicator_heart_rate_max"]
        indicator_heart_rate_max_min <- map["indicator_heart_rate_max_min"]
        indicator_heart_rate_max_max <- map["indicator_heart_rate_max_max"]
        indicator_calorie_min <- map["indicator_calorie_min"]
        indicator_calorie_max <- map["indicator_calorie_max"]
        pkvalue <- map["pkvalue"]
        tableName <- map["tableName"]
        pkfield <- map["pkfield"]
    }
}
