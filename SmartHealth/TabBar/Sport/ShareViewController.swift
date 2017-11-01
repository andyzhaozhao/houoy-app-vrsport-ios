//
//  ShareViewController.swift
//  SmartHealth
//
//  Created by laoniu on 2017/09/17.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import UIKit

class ShareViewController: UIViewController , UITextViewDelegate{

    @IBOutlet weak var textView: UITextView!
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
        let textToShare = "我是且行且珍惜_iOS，欢迎关注我！"
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
