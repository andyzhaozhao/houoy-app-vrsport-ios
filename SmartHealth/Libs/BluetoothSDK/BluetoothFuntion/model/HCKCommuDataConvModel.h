//
//  HCKCommuDataConvModel.h
//  BluetoothDemo
//
//  Created by aa on 17/4/21.
//  Copyright © 2017年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HCKBluetoothGlobal.h"

@interface HCKCommuDataConvModel : NSObject

/**
 当前命令的位置
 */
@property (nonatomic, assign)HCKCommuCommandPostion commandPostion;

/**
 解析后的手环数据
 */
@property (nonatomic, strong)id commuData;

@end
