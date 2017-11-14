//
//  FindEventListCell.swift
//  SmartHealth
//
//  Created by laoniu on 2017/10/29.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import Foundation
class FindEventListCell: UITableViewCell {
    
    private var model: SHEssayListInfoModel?
    @IBOutlet weak var mImageView: UIImageView!
    @IBOutlet weak var mTitleLabel: UILabel!
    @IBOutlet weak var mDetailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func initUI(model: SHEssayListInfoModel?) {
        if(model != nil){
            mImageView.sd_setImage(with: URL(string: (model?.path_thumbnail)! ), placeholderImage: UIImage(named: "item_default"))
        }
        mTitleLabel.text = model?.essay_name
        mDetailLabel.text = model?.essay_subname
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
