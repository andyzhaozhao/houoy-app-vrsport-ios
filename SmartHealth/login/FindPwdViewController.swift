//
//  FindPwdViewController.swift
//  SmartHealth
//
//  Created by laoniu on 2017/09/14.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import UIKit
import Alamofire
class FindPwdViewController: UIViewController {

    @IBOutlet weak var telNumberLabel: UITextField!
    @IBOutlet weak var emailLabel: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func findPwdClick(_ sender: Any) {
        // User reset pwd
        self.view.endEditing(true)
        let email = emailLabel.text ?? ""
        let tel = telNumberLabel.text ?? ""
        if email.isEmpty || tel.isEmpty {
            self.view.makeToast("请输入完整的信息!")
            return;
        }
        let parameters: Parameters = [
            Constants.Password_Email: email
        ]
        let request = Alamofire.request(Constants.ForgetPassword,method: .get, parameters: parameters, encoding: JSONEncoding.default,headers: ApiHelper.getDefaultHeader())
        self.view.isUserInteractionEnabled = false
        request.responseJSON { response in
            self.view.isUserInteractionEnabled = true
            switch response.result {
            case .success(let data):
                Utils.printMsg(msg:"JSON: \(data)")
                let dic = data as! NSDictionary
                let model = SHResetPasswordModel(JSON: dic as! [String : Any])
                guard let themodel = model else {
                    return
                }
                if(themodel.success){
                    self.view.makeToast(themodel.msg)
                } else {
                    self.view.makeToast("重制失败")
                }
            case .failure:
                self.view.makeToast("重制失败")
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
