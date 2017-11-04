//
//  SecondViewController.swift
//  SmartHealth
//
//  Created by laoniu on 2017/08/02.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import UIKit
import Alamofire

class MyPageViewController: CommanViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var settingBtn: UIButton!
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var myTable: UITableView!
    var mArray: Array = ["运动历史记录","我的关注"]
    override func viewDidLoad() {
        super.viewDidLoad()
//        bgImage.image = UIImage(named: "item_default")
//        photoImage.image = UIImage(named: "item_default")
        self.settingBtn .setImage(UIImage.init(named: "settinginfos"), for: .highlighted)
        self.loadData()
    }
    
    func loadData(){
        let pk = UserDefaults.standard.string(forKey:Constants.Login_User_PK) ?? ""
        let parameters: Parameters = [
            Constants.Person_Pk_Person: pk
        ]
        let request = Alamofire.request(Constants.PersonRetrieve,method: .get, parameters: parameters, encoding: URLEncoding.default,headers: ApiHelper.getDefaultHeader())
        self.view.isUserInteractionEnabled = false
        request.responseJSON { response in
            self.view.isUserInteractionEnabled = true
            switch response.result {
            case .success(let data):
                Utils.printMsg(msg:"JSON: \(data)")
                let dic = data as! NSDictionary
                let model = SHPersoninfoModel(JSON: dic as! [String : Any])
                let list = model?.resultData
                guard let theList = list else {
                    return
                }
                let personInfoModel = theList.last
                
                guard let thePersonInfoModel = personInfoModel else {
                    return
                }
                self.nameLabel.text = thePersonInfoModel.person_name
                self.descriptionLabel.text = (thePersonInfoModel.memo == nil) ? "我什么都不想说" : thePersonInfoModel.memo
                self.ageLabel.text = (thePersonInfoModel.age == nil) ? "秘密" : thePersonInfoModel.age
            case .failure:
                self.view.makeToast("获取信息失败")
            }
        }
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

