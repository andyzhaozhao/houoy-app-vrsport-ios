//
//  ShareViewController.swift
//  SmartHealth
//
//  Created by laoniu on 2017/09/17.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import UIKit
import Alamofire
class ShareViewController: UIViewController , UITextViewDelegate{

    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        // Do any additional setup after loading the view.
        self.sendSportData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func sendSportData(){
        let parameters: Parameters = [
            Constants.Record_VRSport_Save_calorie : "555",
            Constants.Record_VRSport_Save_heart_rate : "100",
            Constants.Record_VRSport_Save_heart_rate_max : "128",
        
            Constants.Record_VRSport_Save_Pk_Person : "1",
            Constants.Record_VRSport_Save_Person_Name : "person_name",
        
            Constants.Record_VRSport_Save_Pk_Place : "1",
            Constants.Record_VRSport_Save_Place_Name : "place_name",
        
            Constants.Record_VRSport_Save_Pk_Video : "1",
            Constants.Record_VRSport_Save_Video_Name : "video_name",
        
            Constants.Record_VRSport_Save_Record_Sport_Code : "1",
            Constants.Record_VRSport_Save_Record_Sport_name : "record_sport_name",
        
            Constants.Record_VRSport_Save_Time_End : "2017-10-25 09:09:09",
            Constants.Record_VRSport_Save_Time_Length : "300",
            Constants.Record_VRSport_Save_Time_Start : "2017-10-25 09:09:09"
        ]
        
        let request = Alamofire.request(Constants.RecordVRSportSave,method: .post, parameters: parameters, encoding: JSONEncoding.default,headers: ApiHelper.getDefaultHeader())
        self.view.isUserInteractionEnabled = false
        request.responseJSON { response in
            self.view.isUserInteractionEnabled = true
            switch response.result {
            case .success(let data):
                Utils.printMsg(msg:"JSON: \(data)")
                let dic = data as! NSDictionary
                let model = SHSaveRecordModel(JSON: dic as! [String : Any])
                guard let themodel = model else {
                    return
                }
                if (themodel.success) {
                    self.view.makeToast("保存成功")
                    return
                }
                self.view.makeToast("保存失败")
            case .failure:
                self.view.makeToast("保存失败")
            }
        
        }
    }
    
    
    @IBAction func confirmeClick(_ sender: Any) {
        
//        let arrays = ["Share","I  like Sport."]
//        let activity = UIActivityViewController.init(activityItems: arrays, applicationActivities: nil)
//        // 使用しないアクティビティタイプ
//        let excludedActivityTypes = [
//            UIActivityType.print,
//            UIActivityType.copyToPasteboard,
//            UIActivityType.assignToContact,
//            UIActivityType.addToReadingList,
//            UIActivityType.airDrop,
//            UIActivityType.postToWeibo,
//            UIActivityType.postToTencentWeibo,
//            UIActivityType.message
//        ]
//
//        activity.excludedActivityTypes = excludedActivityTypes
        let textToShare = textView.text
        let imageToShare = UIImage.init(named: "AppIcon.png")
        let urlToShare = NSURL.init(string: "https://github.com")
        let activityItems = [urlToShare,textToShare,imageToShare] as [Any]
        let activity = UIActivityViewController.init(activityItems: activityItems, applicationActivities: nil)
        self.present(activity, animated: true, completion: nil)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
