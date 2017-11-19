//
//  HCKCommuDataConversionTool.h
//  BluetoothDemo
//
//  Created by aa on 17/4/21.
//  Copyright © 2017年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HCKBluetoothGlobal.h"
#import "HCKCommuDataConvModel.h"

@interface HCKCommuDataConversionTool : NSObject

/**
 将手环回复的数据转换成HCKCommuDataConvModel
 
 @param dataString 需要转换的手环数据
 @return HCKCommuDataConvModel
 */
+(HCKCommuDataConvModel *)communicationDataConvToModel:(NSString *)dataString;

@end
