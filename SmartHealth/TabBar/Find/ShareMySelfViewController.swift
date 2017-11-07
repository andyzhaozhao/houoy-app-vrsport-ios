//
//  ShareMySelfViewController.swift
//  SmartHealth
//
//  Created by laoniu on 11/7/17.
//  Copyright © 2017 laoniu. All rights reserved.
//

import UIKit
import Alamofire
extension Date {
    var ticks: UInt64 {
        return UInt64((self.timeIntervalSince1970 + 62_135_596_800) * 10_000_000)
    }
}

class ShareMySelfViewController: UIViewController , UITextViewDelegate{

    @IBOutlet weak var titleTextView: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.isNavigationBarHidden = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    @IBAction func sendDataClick(_ sender: Any) {
        self.sendSportData()
    }
    func sendSportData(){
        let pk = UserDefaults.standard.string(forKey:Constants.Login_User_PK)
        let name = UserDefaults.standard.string(forKey:Constants.Login_User_Name)
        let parameters: Parameters = [
            Constants.Record_Share_Save_Pk_Person :  pk ?? "",
            Constants.Record_Share_Save_Person_Name : name ?? "",
            Constants.Record_Share_Save_Record_Share_Code : Date().ticks,
            Constants.Record_Share_Save_Record_Share_Desc : self.descriptionTextView.text ?? "",
            Constants.Record_Share_Save_Record_Share_Name : self.titleTextView.text ?? ""
        ]
        
        let request = Alamofire.request(Constants.RecordShareSave,method: .post, parameters: parameters, encoding: JSONEncoding.default,headers: ApiHelper.getDefaultHeader())
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
