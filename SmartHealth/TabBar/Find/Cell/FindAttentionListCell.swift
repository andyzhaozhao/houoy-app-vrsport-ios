//
//  FindAttentionListCell.swift
//  SmartHealth
//
//  Created by laoniu on 2017/10/29.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import Foundation
class FindAttentionListCell: UITableViewCell {
    
    private var model: SHAttentionListInfoModel?
    @IBOutlet weak var mImageView: UIImageView!
    @IBOutlet weak var mTitleLabel: UILabel!
    @IBOutlet weak var mDetailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func initUI(model: SHAttentionListInfoModel?) {
        mImageView.image = UIImage(named:"login_main.jpeg")
        mTitleLabel.text = model?.record_share_name
        mDetailLabel.text = model?.person_name
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
