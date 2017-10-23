//
//  SportDetailConditionViewController.swift
//  SmartHealth
//
//  Created by laoniu on 2017/10/21.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import UIKit

class SportDetailConditionViewController: UIViewController {

    @IBOutlet weak var endTimeText: UITextField!
    @IBOutlet weak var startTimeText: UITextField!
    
    var toolBar:UIToolbar!
    var startDatePicker: UIDatePicker!
    var endDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // UIDatePickerの設定
        
        startDatePicker = UIDatePicker()
        startDatePicker.addTarget(self, action: #selector(SportDetailConditionViewController.changedDateEvent(sender:)), for: UIControlEvents.valueChanged)
        startDatePicker.datePickerMode = UIDatePickerMode.date
        endDatePicker = UIDatePicker()
        endDatePicker.addTarget(self, action: #selector(SportDetailConditionViewController.changedDateEvent(sender:)), for: UIControlEvents.valueChanged)
        endDatePicker.datePickerMode = UIDatePickerMode.date
        // UIToolBarの設定
        toolBar = UIToolbar.init(frame:CGRect.init(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40))
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        toolBar.barStyle = .blackTranslucent
        toolBar.tintColor = UIColor.white
        toolBar.backgroundColor = UIColor.black
        let toolBarBtn      = UIBarButtonItem(title: "完了", style: .bordered, target: self, action: #selector(SportDetailConditionViewController.tappedToolBarBtn(sender:)))
        toolBar.items = [toolBarBtn]
        startDatePicker.tag = 1
        startTimeText.inputView = startDatePicker
        startTimeText.inputAccessoryView = toolBar
        endDatePicker.tag = 2
        endTimeText.inputView = endDatePicker
        endTimeText.inputAccessoryView = toolBar
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startTimeClick(_ sender: Any) {
        
    }

    @IBAction func endTimeClick(_ sender: Any) {
        
    }

    // 「完了」を押すと閉じる
    func tappedToolBarBtn(sender: UIBarButtonItem) {
        startTimeText.resignFirstResponder()
        endTimeText.resignFirstResponder()
    }
    //
    func changedDateEvent(sender:UIRefreshControl?){
        if (sender?.tag == 1){
            startTimeText.text = DateUtils.stringFromDate(date: startDatePicker.date, format: "yyyy年MM月dd日")
        } else if (sender?.tag == 2){
            endTimeText.text = DateUtils.stringFromDate(date: endDatePicker.date, format: "yyyy年MM月dd日")
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
