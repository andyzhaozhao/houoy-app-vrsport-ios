//
//  FindCollectionFlowLayout.swift
//  SmartHealth
//
//  Created by laoniu on 2017/09/14.
//  Copyright © 2017年 laoniu. All rights reserved.
//

import UIKit

class FindCollectionFlowLayout: UICollectionViewFlowLayout {

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true;
    }
    
    override func prepare() {
        super.prepare()
        
        
    }
}
