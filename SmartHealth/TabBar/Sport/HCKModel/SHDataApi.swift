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
    
    func sendHeartSportData(model:SHHeartRateDataModel? , videoModel:SHVideoresultDataModel?){
       sendStepSportData(model: nil,videoModel: videoModel)
    }
    
    func createStepModel(data : Dictionary<String, Any>?) -> SHStepDataModel?{
        if(data == nil){
            return SHStepDataModel()
        }
        return SHStepDataModel(JSON: data! )
    }
    
    func sendStepSportData(model:SHStepDataModel? , videoModel:SHVideoresultDataModel?){

        let pk = UserDefaults.standard.string(forKey:Constants.Login_User_PK)
        let name = UserDefaults.standard.string(forKey:Constants.Login_User_Name)
        let parameters: Parameters = [
            Constants.Record_VRSportDetailSave_calorie : "556",
            Constants.Record_VRSportDetailSave_heart : "100",
            Constants.Record_VRSportDetailSave_length : "0",
            
            Constants.Record_VRSport_Save_Pk_Person :  pk ?? "",
            Constants.Record_VRSport_Save_Person_Name : name ?? "",
            
            Constants.Record_VRSport_Save_Pk_Place : videoModel?.pk_folder ?? "",
            Constants.Record_VRSport_Save_Place_Name : "Place" ,
            
            Constants.Record_VRSport_Save_Pk_Video : videoModel?.pk_video ?? "",
            Constants.Record_VRSport_Save_Video_Name : videoModel?.video_name ?? "",
            
            Constants.Record_VRSportDetailSave_Timestamp : "2017-11-21-21-08",
            Constants.Record_VRSportDetailSave_Record_SportDetailCode : Date().ticks,
            Constants.Record_VRSportDetailSave_Record_SportDetailname : Date().ticks
        ]
        
        let request = Alamofire.request(Constants.RecordVRSportDetailSsave,method: .post, parameters: parameters, encoding: JSONEncoding.default,headers: ApiHelper.getDefaultHeader())
        request.responseJSON { response in
            switch response.result {
            case .success(let data):
                Utils.printMsg(msg:"JSON: \(data)")
                let dic = data as! NSDictionary
                let model = SHSaveRecordDetailModel(JSON: dic as! [String : Any])
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
