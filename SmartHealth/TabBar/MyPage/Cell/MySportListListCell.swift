//
//  MyLikeAttentionListCell.swift
//  SmartHealth
//
//  Created by laoniu on 2017/10/29.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import Foundation
class MySportListListCell: UITableViewCell {
    
    private var model: SHLikeRecordHistoryListModel?
    @IBOutlet weak var mImageView: UIImageView!
    @IBOutlet weak var mTitleLabel: UILabel!
    @IBOutlet weak var mDetailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func initUI(model: SHLikeRecordHistoryListModel?) {
        mImageView.image = UIImage(named:"login_main.jpeg")
        mTitleLabel.text = model?.heart_rate
        mDetailLabel.text = model?.heart_rate_max
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
