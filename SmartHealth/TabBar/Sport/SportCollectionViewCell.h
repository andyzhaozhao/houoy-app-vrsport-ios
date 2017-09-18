//
//  SportCollectionViewCell.h
//  SmartHealth
//
//  Created by laoniu on 2017/09/16.
//  Copyright © 2017年 laoniu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SportCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *image;

-(void)loadImage;

@end
