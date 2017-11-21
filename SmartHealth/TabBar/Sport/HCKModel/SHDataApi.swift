//
//  SHDataApi.swift
//  SmartHealth
//
//  Created by laoniu on 11/20/17.
//  Copyright © 2017 laoniu. All rights reserved.
//

import Foundation
import Alamofire
class SHDataApi: NSObject {
    func createHeartModel(data : Dictionary<String, Any>?) -> SHHeartRateDataModel?{
        if(data == nil){
            return SHHeartRateDataModel()
        }
        return SHHeartRateDataModel(JSON: data! )
    }
    
    func sendHeartSportData(model:SHHeartRateDataModel?){
        guard let themodel = model else {
            return
        }
        
        let pk = UserDefaults.standard.string(forKey:Constants.Login_User_PK)
        let name = UserDefaults.standard.string(forKey:Constants.Login_User_Name)
        let parameters: Parameters = [
            Constants.Record_VRSport_Save_calorie : "555",
            Constants.Record_VRSport_Save_heart_rate : "100",
            Constants.Record_VRSport_Save_heart_rate_max : "128",
            
            Constants.Record_VRSport_Save_Pk_Person :  pk ?? "",
            Constants.Record_VRSport_Save_Person_Name : name ?? "",
            
            Constants.Record_VRSport_Save_Pk_Place : "1",
            Constants.Record_VRSport_Save_Place_Name : "Place" ,
            
            //Constants.Record_VRSport_Save_Pk_Video : selectModel?.pk_video ?? "",
            //Constants.Record_VRSport_Save_Video_Name : selectModel?.video_name ?? "",
            
            Constants.Record_VRSport_Save_Record_Sport_Code : "1",
            Constants.Record_VRSport_Save_Record_Sport_name : "record_sport_name",
            //Constants.Record_VRSport_Save_Time_End : selectModel?.videoStartTime ?? "",
            //Constants.Record_VRSport_Save_Time_Start :  selectModel?.videoEndTime ?? ""
        ]
        
        let request = Alamofire.request(Constants.RecordVRSportSave,method: .post, parameters: parameters, encoding: JSONEncoding.default,headers: ApiHelper.getDefaultHeader())
        request.responseJSON { response in
            switch response.result {
            case .success(let data):
                Utils.printMsg(msg:"JSON: \(data)")
                let dic = data as! NSDictionary
                let model = SHSaveRecordModel(JSON: dic as! [String : Any])
                guard let themodel = model else {
                    return
                }
                if (themodel.success) {
                    return
                }
            case .failure:
                Utils.printMsg(msg:"failure")
            }
        }
    }
    
    func createStepModel(data : Dictionary<String, Any>?) -> SHStepDataModel?{
        if(data == nil){
            return SHStepDataModel()
        }
        return SHStepDataModel(JSON: data! )
    }
    
    func sendStepSportData(model:SHStepDataModel?){
        guard let themodel = model else {
            return
        }
        
        let pk = UserDefaults.standard.string(forKey:Constants.Login_User_PK)
        let name = UserDefaults.standard.string(forKey:Constants.Login_User_Name)
        let parameters: Parameters = [
            Constants.Record_VRSport_Save_calorie : "555",
            Constants.Record_VRSport_Save_heart_rate : "100",
            Constants.Record_VRSport_Save_heart_rate_max : "128",
            
            Constants.Record_VRSport_Save_Pk_Person :  pk ?? "",
            Constants.Record_VRSport_Save_Person_Name : name ?? "",
            
            Constants.Record_VRSport_Save_Pk_Place : "1",
            Constants.Record_VRSport_Save_Place_Name : "Place" ,
            
            //Constants.Record_VRSport_Save_Pk_Video : selectModel?.pk_video ?? "",
            //Constants.Record_VRSport_Save_Video_Name : selectModel?.video_name ?? "",
            
            Constants.Record_VRSport_Save_Record_Sport_Code : "1",
            Constants.Record_VRSport_Save_Record_Sport_name : "record_sport_name",
            //Constants.Record_VRSport_Save_Time_End : selectModel?.videoStartTime ?? "",
            //Constants.Record_VRSport_Save_Time_Start :  selectModel?.videoEndTime ?? ""
        ]
        
        let request = Alamofire.request(Constants.RecordVRSportSave,method: .post, parameters: parameters, encoding: JSONEncoding.default,headers: ApiHelper.getDefaultHeader())
        request.responseJSON { response in
            switch response.result {
            case .success(let data):
                Utils.printMsg(msg:"JSON: \(data)")
                let dic = data as! NSDictionary
                let model = SHSaveRecordModel(JSON: dic as! [String : Any])
                guard let themodel = model else {
                    return
                }
                if (themodel.success) {
                    return
                }
            case .failure:
                Utils.printMsg(msg:"failure")
            }
        }
    }
}
