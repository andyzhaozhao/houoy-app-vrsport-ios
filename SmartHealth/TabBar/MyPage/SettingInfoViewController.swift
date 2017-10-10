//
//  SettingInfoViewController.swift
//  SmartHealth
//
//  Created by laoniu on 2017/09/16.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import UIKit

class SettingInfoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate ,UIGestureRecognizerDelegate {

    @IBOutlet weak var iconImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        let iconRecognize = UITapGestureRecognizer.init(target: self, action: #selector(SettingInfoViewController.iconEventClick))
        iconImageView.addGestureRecognizer(iconRecognize)
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
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            iconImageView.image = image
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
