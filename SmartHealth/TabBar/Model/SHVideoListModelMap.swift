//
//  SHPlaceModelMap.swift
//  SmartHealth
//
//  Created by laoniu on 2017/10/26.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import Foundation
import ObjectMapper
class SHVideoListModelMap: NSObject, Mappable{
    var msg: String?
    var success: Bool = false
    var detailMessage: String?
    var statusCode: String?
    var resultDataType: String?
    var resultData: [SHVideoresultDataModel] = []
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

class SHVideoresultDataModel: NSObject, Mappable {
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
    var pk_video: String = ""
    var video_code: String?
    var video_name: String = ""
    var video_desc: String?
    var video_length: String?
    var actor_times: String?
    var actor_calorie: String?
    var path_thumbnail: String = ""
    var path: String = ""
    var pk_folder: String?
    var orderColumnName: String?
    var orderDir: String?
    var pkvalue: String?
    var tableName: String?
    var pkfield: String?
    
    var download: DownladStatus = DownladStatus.NoDownlaod
    var progress: Float = 0
    
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
        pk_video <- map["pk_video"]
        video_code <- map["video_code"]
        video_name <- map["video_name"]
        video_desc <- map["video_desc"]
        video_length <- map["video_length"]
        actor_times <- map["actor_times"]
        actor_calorie <- map["actor_calorie"]
        path_thumbnail <- map["path_thumbnail"]
        path <- map["path"]
        pk_folder <- map["pk_folder"]
        pkvalue <- map["pkvalue"]
        tableName <- map["tableName"]
        pkfield <- map["pkfield"]
    }
}
