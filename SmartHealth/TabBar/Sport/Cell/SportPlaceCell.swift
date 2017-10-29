//
//  SportPlaceCell.swift
//  SmartHealth
//
//  Created by laoniu on 2017/10/29.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import Foundation
class SportPlaceCell: UITableViewCell {
    
    private var model: SHPlaceresultDataModel?
    @IBOutlet weak var mImageView: UIImageView!
    @IBOutlet weak var mTitleLabel: UILabel!
    @IBOutlet weak var mDetailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func initUI(model: SHPlaceresultDataModel?) {
        mImageView.image = UIImage(named:"login_main.jpeg")
        mTitleLabel.text = model?.place_name
        mDetailLabel.text = model?.place_desc
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
