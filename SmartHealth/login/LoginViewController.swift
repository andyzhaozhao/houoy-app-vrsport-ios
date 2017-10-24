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
        self.view.isUserInteractionEnabled = false
        let username = //userIDText.text ?? ""
        "admin"
        let password = // passwordText.text ?? ""
        "1"

        
        // User login
        if (username.isEmpty) || (password.isEmpty) {
            self.view.makeToast("请输入用户名密码")
//            let alert: UIAlertController = UIAlertController(title: "请输入用户名密码", message: "请输入用户名密码", preferredStyle: UIAlertControllerStyle.alert)
//            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
//            })
//            alert .addAction(defaultAction)
//            self.present(alert, animated: true, completion: nil)
            return;
        }

        let parameters: Parameters = [
            Constants.Login_User_Code: username,
            Constants.Login_User_PWD: password
        ]
        
        let request = Alamofire.request(Constants.UserLogin,method: .post, parameters: parameters, headers: ApiHelper.getDefaultHeader())
        request.responseJSON { response in
            self.view.isUserInteractionEnabled = true
            switch response.result {
            case .success(let data):
                print("JSON: \(data)") // serialized json response
                let dic = data as! NSDictionary
                if let success = dic["success"] as? Int {
                    if (success == 1) {
                        //save login
                        self.performSegue(withIdentifier: "toMainTab", sender: nil)
                        return
                    }
                }
                self.view.makeToast("登陆失败")
//                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
//                    print("Data: \(utf8Text)") // original server data as UTF8 string
//                }
            case .failure:
                self.view.makeToast("登陆失败")
            }
            
            //print("Request: \(String(describing: response.request))")   // original url request
            //print("Response: \(String(describing: response.response))") // http url response
            //print("Result: \(response.result)")                         // response serialization result
            

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
