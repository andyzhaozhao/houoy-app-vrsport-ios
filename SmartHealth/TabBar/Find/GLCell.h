//
//  GLCell.h
//  iOSCoverFlow
//
//  Copyright © 2016年 cn.geek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GLCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblName;

- (void)setIndexPath:(NSIndexPath *)idxPath withCount:(int)count;
@end
