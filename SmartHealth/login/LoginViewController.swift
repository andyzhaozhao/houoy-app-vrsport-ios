//
//  LoginViewController.swift
//  SmartHealth
//
//  Created by laoniu on 2017/07/22.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import UIKit
import Crashlytics
import Alamofire
import Toast_Swift
class LoginViewController: CommanViewController{
    
    @IBOutlet weak var userIDText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(Constants.Debug){
            userIDText.text = "admin"
            passwordText.text = "1"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         self.navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.accessibilityIdentifier == "userIDText" {
            passwordText.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    // MARK: - Button Click
    @IBAction func loginBtnClick(_ sender: Any) {
        // Hide the keyboard
        self.view.endEditing(true)
        let username = userIDText.text ?? ""
        let password = passwordText.text ?? ""
        // User login
        if (username.isEmpty) || (password.isEmpty) {
            self.view.makeToast("请输入用户名密码!")
            return;
        }
        let parameters: Parameters = [
            Constants.Login_User_Code: username,
            Constants.Login_User_PWD: password
        ]
        let request = Alamofire.request(Constants.UserLogin,method: .post, parameters: parameters, encoding: JSONEncoding.default,headers: ApiHelper.getDefaultHeader())
        self.view.isUserInteractionEnabled = false
        request.responseJSON { response in
            self.view.isUserInteractionEnabled = true
            switch response.result {
            case .success(let data):
                Utils.printMsg(msg:"JSON: \(data)")
                let dic = data as! NSDictionary
                if let success = dic[Constants.Login_Status_Key] as? Bool {
                    if (success) {
                        //FIXME save login Token
                        self.performSegue(withIdentifier: "toMainTab", sender: nil)
                        return
                    }
                }
                self.view.makeToast("登陆失败")
            case .failure:
                self.view.makeToast("登陆失败")
            }
            //                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
            //                    print("Data: \(utf8Text)") // original server data as UTF8 string
            //                }
            //            let alert: UIAlertController = UIAlertController(title: "请输入用户名密码", message: "请输入用户名密码", preferredStyle: UIAlertControllerStyle.alert)
            //            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            //            })
            //            alert .addAction(defaultAction)
            //            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func noLoginClick(_ sender: Any) {
        
    }
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "MainTabBarController" {
//        if segue.destination is MainTabBarController {
//             NSLog("ab")
//        }
     }
}
