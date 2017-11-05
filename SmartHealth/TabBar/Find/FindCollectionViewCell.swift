//
//  FindCollectionViewCell.swift
//  SmartHealth
//
//  Created by laoniu on 2017/09/15.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import UIKit

class FindCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    func addImage()  {
        imageView.image = UIImage(named: "Login_bg")
    }
}
