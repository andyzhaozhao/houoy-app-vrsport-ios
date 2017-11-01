//
//  SettingInfoViewController.swift
//  SmartHealth
//
//  Created by laoniu on 2017/09/16.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import UIKit
import Alamofire
class SettingInfoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate ,UIGestureRecognizerDelegate {

    @IBOutlet weak var iconImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        let iconRecognize = UITapGestureRecognizer.init(target: self, action: #selector(SettingInfoViewController.iconEventClick))
        iconImageView.addGestureRecognizer(iconRecognize)
        self.loadImageData()
    }
    
    func iconEventClick() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        } else {
            print("PhotoLibrary can't be used.")
        }
    }
    
    func loadImageData(){
        let pk = UserDefaults.standard.string(forKey:Constants.Login_User_PK) ?? ""
        let parameters: Parameters = [
            Constants.Login_User_PK: pk
        ]
        let request = Alamofire.request(Constants.PersonPortrait,method: .get, parameters: parameters, encoding: URLEncoding.default,headers: ApiHelper.getDefaultHeader())
        self.view.isUserInteractionEnabled = false
        request.responseJSON { response in
            self.view.isUserInteractionEnabled = true
            switch response.result {
            case .success(let data):
                Utils.printMsg(msg:"JSON: \(data)")
                let dic = data as! NSDictionary
                let model = SHPersonPortraitModel(JSON: dic as! [String : Any])
                guard let theModel = model else {
                    return
                }
                if theModel.success {
                    guard let theData = theModel.resultData else {
                        return
                    }
                    self.iconImageView.image = UIImage(data: theData)
                } else {
                    self.view.makeToast("获取头像失败")
                }
            case .failure:
                self.view.makeToast("获取信息失败")
            }
        }
    }
    
    func uploadImageData(){
        let pk = UserDefaults.standard.string(forKey:Constants.Login_User_PK) ?? ""
        let parameters: Parameters = [
            Constants.Person_Person_File:UIImagePNGRepresentation(iconImageView.image!) as! Data,
            Constants.Login_User_PK: pk
        ]
        let request = Alamofire.request(Constants.PersonUpload,method: .post, parameters: parameters, encoding: URLEncoding.default,headers: ApiHelper.getDefaultHeader())
        self.view.isUserInteractionEnabled = false
        request.responseJSON { response in
            self.view.isUserInteractionEnabled = true
            switch response.result {
            case .success(let data):
                Utils.printMsg(msg:"JSON: \(data)")
                let dic = data as! NSDictionary
    
                
            case .failure:
                self.view.makeToast("获取信息失败")
            }
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            iconImageView.image = image
            uploadImageData()
        }
        picker.dismiss(animated: true, completion: nil);
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
