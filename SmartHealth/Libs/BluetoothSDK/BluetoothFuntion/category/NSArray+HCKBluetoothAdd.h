//
//  NSArray+HCKBluetoothAdd.h
//  BluetoothDemo
//
//  Created by aa on 17/5/8.
//  Copyright © 2017年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (HCKBluetoothAdd)

/**
 把originalArray数组按照range进行截取，生成一个新的数组并返回该数组
 
 @param originalArray 原数组
 @param range 截取范围
 @return 截取后生成的数组
 */
+ (NSArray *)interceptionOfArray:(NSArray *)originalArray subRange:(NSRange)range;

@end
