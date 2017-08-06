//
//  LoginViewController.swift
//  SmartHealth
//
//  Created by laoniu on 2017/07/22.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import UIKit

class LoginViewController: CommanViewController{
    
    @IBOutlet weak var userIDText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
//        
//        // User login
//        if (userIDText.text?.isEmpty)! || (passwordText.text?.isEmpty)! {
//            let alert: UIAlertController = UIAlertController(title: "请输入用户名密码", message: "请输入用户名密码", preferredStyle: UIAlertControllerStyle.alert)
//            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
//            })
//            alert .addAction(defaultAction)
//            self.present(alert, animated: true, completion: nil)
//        } else {
//        //API
            performSegue(withIdentifier: "toMainTab", sender: nil)
//
//        }
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
