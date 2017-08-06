//
//  RegisterViewController.swift
//  SmartHealth
//
//  Created by laoniu on 2017/08/03.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import UIKit

class RegisterViewController: CommanViewController {
    
    @IBOutlet weak var userIDText: UITextField!
    @IBOutlet weak var telText: UITextField!
    @IBOutlet weak var codeText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var confirmPasswordText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.accessibilityIdentifier! {
        case "userIDText":
            telText.becomeFirstResponder()
        case "telText":
            codeText.becomeFirstResponder()
        case "codeText":
            passwordText.becomeFirstResponder()
        case "passwordText":
            confirmPasswordText.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }

    // MARK: - Button Click
    @IBAction func codeBtnClick(_ sender: Any) {
        //API
    }
    
    @IBAction func registerBtnClick(_ sender: Any) {
        // Hide the keyboard
        self.view.endEditing(true)
        
        // User register
//        if (userIDText.text?.isEmpty)! || (telText.text?.isEmpty)! || (codeText.text?.isEmpty)! || (passwordText.text?.isEmpty)! || (confirmPasswordText.text?.isEmpty)!{
//            let alert: UIAlertController = UIAlertController(title: "信息不完整", message: "请输入完整信息", preferredStyle: UIAlertControllerStyle.alert)
//            let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
//            })
//            alert .addAction(defaultAction)
//            self.present(alert, animated: true, completion: nil)
//        } else {
            //API
            performSegue(withIdentifier: "toMainTab", sender: nil)
//        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}
