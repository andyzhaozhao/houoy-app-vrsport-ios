//
//  SportVideoListCell.swift
//  SmartHealth
//
//  Created by laoniu on 2017/10/29.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import Foundation
class SportVideoListCell: UITableViewCell {
    
    private var model: SHVideoresultDataModel?
    @IBOutlet weak var mImageView: UIImageView!
    @IBOutlet weak var mTitleLabel: UILabel!
    @IBOutlet weak var mDetailLabel: UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var mStatus: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func initUI(model: SHVideoresultDataModel?) {
        mImageView.image = UIImage(named:"item_default")
        mTitleLabel.text = model?.video_name
        mDetailLabel.text = model?.video_desc
        if let progress = model?.progress {
            if(progress > 0){
                progressView.progress = progress
                progressView.isHidden = false
            } else {
                progressView.isHidden = true
            }
        }else {
            progressView.isHidden = true
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
