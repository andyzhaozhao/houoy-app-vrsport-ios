//
//  FindAttentionListCell.swift
//  SmartHealth
//
//  Created by laoniu on 2017/08/05.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import UIKit

class FindAttentionTableViewCell: UITableViewCell {

    var dataDic: [String: String] = ["image":"item_default", "title":"标题", "detail":"详细内容"]
    @IBOutlet weak var mImageView: UIImageView!
    @IBOutlet weak var mTitleLabel: UILabel!
    @IBOutlet weak var mDetailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func initUI() {
        mImageView.image = UIImage(named: dataDic["image"]!)
        mTitleLabel.text = dataDic["title"]!
        mDetailLabel.text = dataDic["detail"]!
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

