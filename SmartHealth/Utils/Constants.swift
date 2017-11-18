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
    
    //dopwnload
    public static let ModelKey = "modelkey"
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
    
    //video path
    //http://47.94.6.120/video/video/video1/Wildlife.MP4
    public static let Download_Base_Link = "http://47.94.6.120/video/"
    public static let Download_Download = "SHDownloads/"
    public static let Download_Temp = "SHTemp/"
    public static let Download_File_Divide = "/"
    
    //splash parameter
    public static let SH_Splash = "splash"
    //place parameter
    public static let List_Pk_Folder = "pk_folder"
    
    //reset pwd
    
    public static let Password_Email = "email"
    public static let Password_User_PK = "pk_person"
    
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
    public static let Register_Email = "email"
    // person parameter
    public static let Person_Pk = "pk"
    public static let Person_Pk_Person = "pk_person"
    public static let Person_Person_File = "file"
    public static let Person_Person_Image = "image"
    
    //recordVR sport save parameter
    public static let Record_VRSport_Save_calorie = "calorie"
    public static let Record_VRSport_Save_heart_rate = "heart_rate"
    public static let Record_VRSport_Save_heart_rate_max = "heart_rate_max"
    
    public static let Record_VRSport_Save_Pk_Person = "pk_person"
    public static let Record_VRSport_Save_Person_Name = "person_name"
    
    public static let Record_VRSport_Save_Pk_Place = "pk_place"
    public static let Record_VRSport_Save_Place_Name = "place_name"
    
    public static let Record_VRSport_Save_Pk_Video = "pk_video"
    public static let Record_VRSport_Save_Video_Name = "video_name"
    
    public static let Record_VRSport_Save_Record_Sport_Code = "record_sport_code"
    public static let Record_VRSport_Save_Record_Sport_name = "record_sport_name"
    
    public static let Record_VRSport_Save_Time_End = "time_end"
    public static let Record_VRSport_Save_Time_Length = "time_length"
    public static let Record_VRSport_Save_Time_Start = "time_start"
    
    public static let Register_indicator_calorie_max = "indicator_calorie_max"
    public static let Register_indicator_calorie_min = "indicator_calorie_min"
    public static let Register_indicator_heart_rate_max = "indicator_heart_rate_max"
    public static let Register_indicator_heart_rate_max_max = "indicator_heart_rate_max_max"
    public static let Register_indicator_heart_rate_max_min = "indicator_heart_rate_max_min"
    public static let Register_indicator_heart_rate_min = "indicator_heart_rate_min"

    //record Share
    public static let Record_Share_Save_Pk_Person = "pk_person"
    public static let Record_Share_Save_Person_Name = "person_name"
    public static let Record_Share_Save_Record_Share_Code = "record_share_code"
    public static let Record_Share_Save_Record_Share_Desc = "record_share_desc"
    public static let Record_Share_Save_Record_Share_Name = "record_share_name"
    
    //URL
    private static let BaseUrl8889 = "http://182.92.128.240:8889/api"
    private static let BaseUrl8888 = "http://182.92.128.240:8888/api"
    public static let SigninSystemMobile = BaseUrl8889+"/login/signinSystemMobile"
    public static let FolderVideoRetrieve = BaseUrl8888+"/folderVideo/retrieveMobile"
    public static let VideoRetrieve = BaseUrl8888+"/video/retrieveMobile"
    public static let RecordShareRetrieve = BaseUrl8889+"/recordShare/retrieveMobile"
    public static let EssayRetrieve = BaseUrl8888+"/essay/retrieveMobile"
    public static let RecordVRSportRetrieve = BaseUrl8889+"/recordVRSport/retrieveMobile"
    public static let RecordVRSportSave = BaseUrl8889+"/recordVRSport/save"
    public static let RecordShareSave = BaseUrl8889+"/recordShare/save"
    public static let PersonFollowRetrieve = BaseUrl8889+"/personFollow/retrieveMobile"
    public static let PersonFollowSave = BaseUrl8889+"/personFollow/save"
    public static let PersonSave = BaseUrl8889+"/person/save"
    public static let PersonRetrieve = BaseUrl8889+"/person/retrieveMobile"
    public static let PersonPortrait = BaseUrl8889+"/person/portrait"
    public static let PersonUpload = BaseUrl8889+"/person/uploadMobile"
    public static let ForgetPassword = BaseUrl8889+"/login/forgetPassword"
    
    public static let iTunesLink = "itms://itunes.apple.com/us/app/apple-store/id375380948?mt=8"
}
