//
//  NSString+HCKBluetoothAdd.h
//  BluetoothDemo
//
//  Created by aa on 17/5/8.
//  Copyright © 2017年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HCKAlarmClockModel.h"

@interface NSString (HCKBluetoothAdd)

/**
 判断当前字符串是否是mac地址
 
 @return YES:是mac地址，NO:不是mac地址
 */
- (BOOL)isMacAddress;

/**
 判断当时字符串是否是mac地址的其中四位
 
 @return YES,NO
 */
- (BOOL)isMacAddressLowFour;

#pragma mark -
/**
 字符串转成相应的NSData数据
 
 @return 转换后的NSData
 */
- (NSData *)stringToData;

/**
 *  将二进制数据转换成十六进制字符串
 *
 *  @param sourceData 二进制数据
 *
 *  @return 十六进制字符串
 */
+ (NSString *)hexStringFromData:(NSData *)sourceData;

//将16进制转化为二进制

+(NSString *)getBinaryByhex:(NSString *)hex;

/**
 根据传入的数组来确定一个字节的16进制数
 
 @param paramList 传入的数据必须是@[@"00",@"00",@"00",@"00",@"00",@"00",@"00",@"00"]
 @return 16进制数据
 */
+ (NSString *)getHexStringWithArray:(NSArray *)paramList;

/**
 根据闹钟类型转换成相应的手环相应数据
 
 @param type 闹钟类型
 @return 手环识别的16进制数据
 */
+ (NSString *)getAlarmClockTypeInfo:(alarmClockType)type;

/**
 根据传入的闹钟开启时间设定数据来返回手环识别的16进账数据
 
 @param clockSettings 闹钟开启和关闭的日期(周一至周日)数组，依次为周一至周日，相应位置@"01"代表开启，@"00"代表关闭，@[@"00",@"00",@"00",@"00",@"00",@"00",@"00"]代表周一至周日全部关闭，@[@"01",@"01",@"01",@"01",@"01",@"01",@"01"]代表周一至周日全部开启
 @return 手环识别的16进制数据
 */
+ (NSString *)getAlarmClockSettings:(NSArray *)clockSettings;

@end
