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
    
    //login parmater.
    public static let Login_User_Code = "user_code"
    public static let Login_User_PWD = "user_password"
    
    //login userdefault
    public static let Login_User_Name = "user_name"
    public static let Login_User_PK = "user_id"
    
    //video list parmater.
    public static let Video_List_Start = "start"
    public static let Video_List_Length = "length"
    public static let Video_List_Length_Value = 10
    public static let Video_List_OrderColumnName = "orderColumnName"
    public static let Video_List_OrderColumnName_Value = "video_name"
    public static let Video_List_OrderDir = "orderDir"
    public static let Video_List_OrderDir_Desc = "desc"
    public static let Video_List_OrderDir_Asc = "asc"

    
    //URL
    private static let BaseUrl8889 = "http://182.92.128.240:8889/api"
    private static let BaseUrl8888 = "http://182.92.128.240:8888/api"
    public static let SigninSystemMobile = BaseUrl8889+"/login/signinSystemMobile"
    public static let PlaceRetrieve = BaseUrl8889+"/place/retrieve"
    public static let VideoRetrieve = BaseUrl8888+"/video/retrieveMobile"
    
    public static let iTunesLink = "itms://itunes.apple.com/us/app/apple-store/id375380948?mt=8"
}
