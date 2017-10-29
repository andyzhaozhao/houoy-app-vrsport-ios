//
//  SHLoginModel.swift
//  SmartHealth
//
//  Created by laoniu on 2017/10/29.
//  Copyright © 2017年 laoniu. All rights reserved.
//
import Foundation
import ObjectMapper
class SHLoginModel: Mappable {
    var msg: String?
    var success: Bool
    var detailMessage: String?
    var statusCode: String?
    var resultDataType: String?
    var resultData: SHLoginresultDataModel?
    var uploadId: String?
    var def1: String?
    var def2: String?
    var def3: String?
    var def4: String?
    var def5: String?
    required init(map: Map) {
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
        def4 <- map["def4"]
        def5 <- map["def5"]
    }
}

class SHLoginresultDataModel: Mappable {
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
    var pk_user: String?
    var pk_role: String?
    var user_code: String?
    var user_name: String?
    var user_password: String?
    var email: String?
    var mobile: String?
    var be_locked: String?
    var abletime: String?
    var disabletime: String?
    var be_enterprise: String?
    var be_me: String?
    var be_operation: String?
    var be_console: String?
    var be_actived: String?
    var locked_reason: String?
    var reg_ts: String?
    var last_login_ts: String?
    var encrypted_password: String?
    var avatar_url: String?
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
        pk_user <- map["pk_user"]
        pk_role <- map["pk_role"]
        user_code <- map["user_code"]
        user_name <- map["user_name"]
        user_password <- map["user_password"]
        email <- map["email"]
        mobile <- map["mobile"]
        be_locked <- map["be_locked"]
        abletime <- map["abletime"]
        disabletime <- map["disabletime"]
        be_enterprise <- map["be_enterprise"]
        be_me <- map["be_me"]
        be_operation <- map["be_operation"]
        be_console <- map["be_console"]
        be_actived <- map["be_actived"]
        locked_reason <- map["locked_reason"]
        reg_ts <- map["reg_ts"]
        last_login_ts <- map["last_login_ts"]
        encrypted_password <- map["encrypted_password"]
        avatar_url <- map["avatar_url"]
        pkvalue <- map["pkvalue"]
        tableName <- map["tableName"]
        pkfield <- map["pkfield"]
    }
}
/*
 {
 "success": true,
 "msg": "查询成功",
 "detailMessage": null,
 "statusCode": null,
 "resultDataType": null,
 "resultData": {
 "memo": null,
 "def1": null,
 "def2": null,
 "def3": null,
 "def4": null,
 "def5": null,
 "be_std": null,
 "ts": "2017-10-23 19:31:04.0",
 "dr": null,
 "start": null,
 "length": null,
 "orderColumnName": null,
 "orderDir": null,
 "pk_user": "4",
 "pk_role": "1",
 "user_code": "admin",
 "user_name": "admin",
 "user_password": "jlehfdffcfmohiag",
 "email": "sss",
 "mobile": null,
 "be_locked": "N",
 "abletime": null,
 "disabletime": null,
 "be_enterprise": null,
 "be_me": null,
 "be_operation": null,
 "be_console": null,
 "be_actived": null,
 "locked_reason": null,
 "reg_ts": null,
 "last_login_ts": null,
 "encrypted_password": null,
 "avatar_url": null,
 "pkvalue": "4",
 "tableName": "sm_user",
 "pkfield": "pk_user"
 },
 "uploadId": null,
 "def1": null,
 "def2": null,
 "def3": null,
 "def4": null,
 "def5": null
 }
 */
