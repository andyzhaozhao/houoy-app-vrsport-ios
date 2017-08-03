//
//  LoginViewController.swift
//  SmartHealth
//
//  Created by laoniu on 2017/07/22.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import UIKit

class LoginViewController: CommanViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigation(hidden: true, title: "登录")
        setTabbar(hidden: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
