//
//  Constant.swift
//  SmartHealth
//
//  Created by laoniu on 2017/09/18.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import Foundation

struct Constants {
    public static let Debug = true
    
    //common
    public static let ContentType = "Content-Type"
    public static let ContentTypeJson = "application/json"
    public static let Accept = "Accept"
    public static let List_Start = "start"
    public static let List_Length = "length"
    public static let List_Length_Value = 10
    public static let List_OrderColumnName = "orderColumnName"
    public static let List_OrderDir = "orderDir"
    public static let List_OrderDir_Desc = "desc"
    public static let List_OrderDir_Asc = "asc"
    public static let List_User_PK = "pk_person"
    
    //login parameter.
    public static let Login_User_Code = "user_code"
    public static let Login_User_PWD = "user_password"
    
    //login userdefault
    public static let Login_User_Name = "person_name"
    public static let Login_User_PK = "pk_person"
    
    //video list parameter.
    public static let Video_List_OrderColumnName_Value = "video_name"
    //essay list parameter.
    public static let Essay_List_OrderColumnName_Value = "ts"
    public static let Essay_List_Type = "pk_type"
    public static let Essay_List_Type_32 = 32
    public static let Essay_List_Type_33 = 33
    //attention list parameter.
    public static let Attention_List_OrderColumnName_Value = "ts"
    //recordVRSport list parameter.
    public static let RecordVRSport_List_OrderColumnName_Value = "ts"
    //attention list parameter.
    public static let PersonFollow_List_OrderColumnName_Value = "person_name"
    
    //attention parameter.
    public static let Follow_Person_Name = "follow_person_name"
    public static let Follow_Person_PK = "follow_pk_person"
    // register parameter
    public static let Register_Password = "password"
    public static let Register_Person_Code = "person_code"
    public static let Register_Person_name = "person_name"
    public static let Register_Mobile = "mobile"
    //URL
    private static let BaseUrl8889 = "http://182.92.128.240:8889/api"
    private static let BaseUrl8888 = "http://182.92.128.240:8888/api"
    public static let SigninSystemMobile = BaseUrl8889+"/login/signinSystemMobile"
    public static let PlaceRetrieve = BaseUrl8889+"/place/retrieve"
    public static let VideoRetrieve = BaseUrl8888+"/video/retrieveMobile"
    public static let RecordShareRetrieve = BaseUrl8889+"/recordShare/retrieveMobile"
    public static let EssayRetrieve = BaseUrl8888+"/essay/retrieveMobile"
    public static let RecordVRSportRetrieve = BaseUrl8889+"/recordVRSport/retrieveMobile"
    public static let PersonFollowRetrieve = BaseUrl8889+"/personFollow/retrieveMobile"
    public static let PersonFollowSave = BaseUrl8889+"/personFollow/save"
    public static let PersonSave = BaseUrl8889+"/person/save"
    
    public static let iTunesLink = "itms://itunes.apple.com/us/app/apple-store/id375380948?mt=8"
}
