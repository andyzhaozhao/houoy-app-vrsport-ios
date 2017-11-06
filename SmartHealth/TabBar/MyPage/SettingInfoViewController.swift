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
        let imageData = UIImageJPEGRepresentation(iconImageView.image!, 0.2) as Data?
        let parameters: Parameters = [
            //Constants.Person_Person_File:imageData!,
            Constants.Login_User_PK: pk
        ]
        let header: HTTPHeaders = [
            Constants.ContentType: "multipart/form-data",
            Constants.Accept: Constants.ContentTypeJson
        ]
        let link = Constants.PersonUpload+"?"+Constants.Login_User_PK+"="+pk
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imageData!, withName: Constants.Person_Person_File)
            for (key, value) in parameters {
                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
            
        }, to: link, method: .post, headers: header, encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    debugPrint(response)
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        })
        
//        Alamofire.upload(
//            multipartFormData: { multipartFormData in
//                multipartFormData.append(imageData!, withName: Constants.Person_Person_File)
//        },
//            to: link,
//            encodingCompletion: { encodingResult in
//                switch encodingResult {
//                case .success(let upload, _, _):
//                    upload.responseJSON { response in
//                        debugPrint(response)
//                    }
//                case .failure(let encodingError):
//                    print(encodingError)
//                }
//        }
//        )

//
//        let request = Alamofire.upload(imageData!, to: Constants.PersonUpload+"?"+Constants.Login_User_PK+"="+pk, method: .post, headers: header)
//        request.responseJSON { (response) in
//            debugPrint(response)
//        }
        
      //  Alamofire.upload(imageData, to: "https://httpbin.org/post").responseJSON { response in
      //      debugPrint(response)
      //  }
//
//        let request = Alamofire.request(Constants.PersonUpload,method: .post, parameters: parameters, encoding: URLEncoding.default,headers:header)
//        self.view.isUserInteractionEnabled = false
//        request.responseJSON { response in
//            self.view.isUserInteractionEnabled = true
//            switch response.result {
//            case .success(let data):
//                Utils.printMsg(msg:"JSON: \(data)")
//                let dic = data as! NSDictionary
//
//
//            case .failure:
//                self.view.makeToast("获取信息失败")
//            }
//        }
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
