//
//  SHFolderModelMap.swift
//  SmartHealth
//
//  Created by laoniu on 2017/10/26.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import Foundation
import ObjectMapper
class SHFolderModelMap: Mappable {
    var msg: String?
    var success: Bool = false
    var detailMessage: String?
    var statusCode: String?
    var resultDataType: String?
    var resultData: [SHFolderresultDataModel] = []
    var uploadId: String?
    var def1: String?
    var def2: String?
    var def3: String?
    var def4: String?
    var def5: String?
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
    }
}

class SHFolderresultDataModel: Mappable {
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
    var nodes: [SHFolderresultDataModel] = []
    var pk_folder: String?
    var folder_code: String?
    var folder_name: String?
    var folder_desc: String?
    var pk_parent: String?
    var text: String?

    var pkvalue: String?
    var tableName: String?
    var parentPKField: String?
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
        nodes <- map["nodes"]
        pk_folder <- map["pk_folder"]
        folder_code <- map["folder_code"]
        folder_name <- map["folder_name"]
        folder_desc <- map["folder_desc"]
        pk_parent <- map["pk_parent"]
        text <- map["text"]
        pkvalue <- map["pkvalue"]
        tableName <- map["tableName"]
        parentPKField <- map["parentPKField"]
        pkfield <- map["pkfield"]
    }
}
