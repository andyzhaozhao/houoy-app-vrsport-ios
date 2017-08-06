//
//  FirstViewController.swift
//  SmartHealth
//
//  Created by laoniu on 2017/08/02.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import UIKit

class CommanViewController: UIViewController, UITextFieldDelegate {
    
    var navigationShow:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Tap the view, end edit
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

