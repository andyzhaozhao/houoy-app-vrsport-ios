//
//  ShareViewController.swift
//  SmartHealth
//
//  Created by laoniu on 2017/09/17.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import UIKit

class ShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func confirmeClick(_ sender: Any) {
        let arrays = ["Share","I  like Sport."]
        let activity = UIActivityViewController.init(activityItems: arrays, applicationActivities: nil)
        self.present(activity, animated: true, completion: nil)
    }
    @IBOutlet weak var cancelClick: NSLayoutConstraint!
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
