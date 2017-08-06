//
//  SecondViewController.swift
//  SmartHealth
//
//  Created by laoniu on 2017/08/02.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import UIKit

class MyPageViewController: CommanViewController {

    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var sportTimeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var myTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bgImage.image = UIImage(named: "login_main.jpeg")
        photoImage.image = UIImage(named: "login_main.jpeg")
        nameLabel.text = "MyName"
        descriptionLabel.text = "Who am I?"
        ageLabel.text = "40"
        sportTimeLabel.text = "2015/04/12 13:00"
        distanceLabel.text = "12"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigation(hidden: true)
    }


}

