//
//  FindDetailViewController.swift
//  SmartHealth
//
//  Created by laoniu on 2017/08/06.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import UIKit
import Alamofire
class FindDetailViewController: UIViewController {

    var noteModel: SHEssayListInfoModel?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var detailText: UITextView!
    @IBOutlet weak var attentionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    self.navigationController?.isNavigationBarHidden = false
        self.titleLabel.text = noteModel?.essay_name
        self.subTitleLabel.text = noteModel?.essay_subname
        self.detailText.text = noteModel?.essay_content
        self.detailText.attributedText = noteModel?.essay_content?.htmlAttributedString()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func attentionButtonClick(_ sender: Any) {
        let username = UserDefaults.standard.string(forKey:Constants.Login_User_Name) ?? ""
        let user_pk = UserDefaults.standard.string(forKey:Constants.Login_User_PK) ?? ""
        guard let theNoteModel = self.noteModel else {
            return
        }
        let parameters: Parameters = [
            Constants.Login_User_Name: username,
            Constants.Login_User_PK: user_pk,
            Constants.Follow_Person_Name: theNoteModel.person_name,
            Constants.Follow_Person_PK: theNoteModel.pk_person,
        ]
        let request = Alamofire.request(Constants.PersonFollow,method: .post, parameters: parameters, encoding: JSONEncoding.default,headers: ApiHelper.getDefaultHeader())
        self.view.isUserInteractionEnabled = false
        request.responseJSON { response in
            self.view.isUserInteractionEnabled = true
            switch response.result {
            case .success(let data):
                Utils.printMsg(msg:"JSON: \(data)")
                let dic = data as! NSDictionary
                let model = SHFindPersonFollow(JSON: dic as! [String : Any])
                guard let themodel = model else {
                    return
                }
                if (themodel.success) {
                    self.view.makeToast("关注成功")
                    return
                }
                self.view.makeToast("关注失败")
            case .failure:
                self.view.makeToast("关注失败")
            }
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
