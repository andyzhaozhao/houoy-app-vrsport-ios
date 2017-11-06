//
//  SHPersoninfoModel.swift
//  SmartHealth
//
//  Created by laoniu on 2017/10/29.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import Foundation
import ObjectMapper
class SHPersoninfoModel: Mappable {
    var msg: String?
    var success: Bool = false
    var detailMessage: String?
    var statusCode: String?
    var resultDataType: String?
    var resultData: [SHPersonListModel] = []
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

class SHPersonListModel: Mappable {
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
    var pk_person: String?
    var person_code: String?
    var person_alias: String?
    var person_name: String?
    var password: String?
    var mobile: String?
    var email: String?
    var identity: String?
    var age: String?
    var address: String?
    var birthday: String?
    var birthplace: String?
    var country: String?
    var portraitPath: String?
    var province: String?
    var city: String?
    var town: String?
    var village: String?
    var job: String?
    var income: String?
    var has_house: String?
    var has_car: String?
    var marriage: String?
    var emotion_count: String?
    var mate_type: String?
    var habbit: String?
    var family: String?
    var health: String?
    var single_long: String?
    var enable_marriagetime: String?
    var idea_love: String?
    var idea_value: String?
    var idea_goal: String?
    var idea_swear: String?
    var img1_comment: String?
    var img2_comment: String?
    var img3_comment: String?
    var img4_comment: String?
    var img5_comment: String?
    var img1: String?
    var img2: String?
    var img3: String?
    var img4: String?
    var img5: String?
    var safe_state: String?
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
        pk_person <- map["pk_person"]
        person_code <- map["person_code"]
        person_alias <- map["person_alias"]
        person_name <- map["person_name"]
        password <- map["password"]
        mobile <- map["mobile"]
        email <- map["email"]
        identity <- map["identity"]
        age <- map["age"]
        address <- map["address"]
        birthday <- map["birthday"]
        birthplace <- map["birthplace"]
        country <- map["country"]
        portraitPath <- map["portraitPath"]
        province <- map["province"]
        city <- map["city"]
        town <- map["town"]
        village <- map["village"]
        job <- map["job"]
        income <- map["income"]
        has_house <- map["has_house"]
        has_car <- map["has_car"]
        marriage <- map["marriage"]
        emotion_count <- map["emotion_count"]
        mate_type <- map["mate_type"]
        habbit <- map["habbit"]
        family <- map["family"]
        health <- map["health"]
        single_long <- map["single_long"]
        enable_marriagetime <- map["enable_marriagetime"]
        idea_love <- map["idea_love"]
        idea_value <- map["idea_value"]
        idea_goal <- map["idea_goal"]
        idea_swear <- map["idea_swear"]
        img1_comment <- map["img1_comment"]
        img2_comment <- map["img2_comment"]
        img3_comment <- map["img3_comment"]
        img4_comment <- map["img4_comment"]
        img5_comment <- map["img5_comment"]
        img1 <- map["img1"]
        img2 <- map["img2"]
        img3 <- map["img3"]
        img4 <- map["img4"]
        img5 <- map["img5"]
        safe_state <- map["safe_state"]
        pkvalue <- map["pkvalue"]
        tableName <- map["tableName"]
        pkfield <- map["pkfield"]
    }
}
