//
//  SHEssayInfoModel.swift
//  SmartHealth
//
//  Created by laoniu on 2017/10/29.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import Foundation
import ObjectMapper
class SHEssayInfoModel: Mappable {
    var msg: String?
    var success: Bool = false
    var detailMessage: String?
    var statusCode: String?
    var resultDataType: String?
    var resultData: [SHEssayListInfoModel] = []
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

class SHEssayListInfoModel: Mappable {
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
    var pk_essay: String?
    var essay_code: String?
    var essay_name: String?
    var essay_subname: String?
    var essay_content: String?
    var is_publish: String?
    var ts_start: String?
    var ts_end: String?
    var pk_type: String?
    var path_thumbnail: String?
    var pk_person: String = ""
    var person_name: String = ""
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
        pk_essay <- map["pk_essay"]
        essay_code <- map["essay_code"]
        essay_name <- map["essay_name"]
        essay_subname <- map["essay_subname"]
        essay_content <- map["essay_content"]
        is_publish <- map["is_publish"]
        ts_start <- map["ts_start"]
        ts_end <- map["ts_end"]
        pk_type <- map["pk_type"]
        path_thumbnail <- map["path_thumbnail"]
        pk_person <- map["pk_person"]
        person_name <- map["pk_person"]
        pkvalue <- map["pkvalue"]
        tableName <- map["tableName"]
        pkfield <- map["pkfield"]
    }
}
