//
//  MyLikeAttentionListCell.swift
//  SmartHealth
//
//  Created by laoniu on 2017/10/29.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import Foundation
class MyLikeAttentionListCell: UITableViewCell {
    
    private var model: SHLikeAttentionListModel?
    @IBOutlet weak var mImageView: UIImageView!
    @IBOutlet weak var mTitleLabel: UILabel!
    @IBOutlet weak var mDetailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func initUI(model: SHLikeAttentionListModel?) {
        mImageView.image = UIImage(named:"item_default")
        mTitleLabel.text = model?.follow_person_name
        mDetailLabel.text = model?.follow_pk_person
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
