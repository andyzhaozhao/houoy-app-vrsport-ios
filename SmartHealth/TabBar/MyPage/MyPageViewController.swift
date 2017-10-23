//
//  SecondViewController.swift
//  SmartHealth
//
//  Created by laoniu on 2017/08/02.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import UIKit

class MyPageViewController: CommanViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var sportTimeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var myTable: UITableView!
    var mArray: Array = ["运动历史记录","我的关注"]
    override func viewDidLoad() {
        super.viewDidLoad()
//        bgImage.image = UIImage(named: "login_main.jpeg")
//        photoImage.image = UIImage(named: "login_main.jpeg")
        nameLabel.text = "张三"
        descriptionLabel.text = "我是谁？我从哪里来？"
        ageLabel.text = "40"
        sportTimeLabel.text = "2015/04/12 13:00"
        distanceLabel.text = "12"
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0) {
            performSegue(withIdentifier: "showSportDetail", sender: nil)
        } else if (indexPath.row == 1) {
            performSegue(withIdentifier: "showMyLikeDetail", sender: nil)
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = mArray[indexPath.row]
        cell.accessoryType =  UITableViewCellAccessoryType.disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mArray.count
    }
}

