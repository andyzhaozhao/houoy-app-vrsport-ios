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
    
    //URL
    private static let BaseUrl = "http://182.92.128.240:8889/api"
    public static let SigninSystemMobile = BaseUrl+"/login/signinSystemMobile"
    public static let PlaceRetrieve = BaseUrl+"/place/retrieve"
    
    public static let iTunesLink = "itms://itunes.apple.com/us/app/apple-store/id375380948?mt=8"
}
