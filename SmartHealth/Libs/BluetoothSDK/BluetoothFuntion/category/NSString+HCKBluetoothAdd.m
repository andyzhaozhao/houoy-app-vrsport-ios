//
//  NSString+HCKBluetoothAdd.m
//  BluetoothDemo
//
//  Created by aa on 17/5/8.
//  Copyright © 2017年 HCK. All rights reserved.
//

#import "NSString+HCKBluetoothAdd.h"
#import "HCKBluetoothGlobal.h"

@implementation NSString (HCKBluetoothAdd)

#pragma mark - Private Method

- (BOOL)isRealNumbers{
    NSString *regex = @"^(0|[1-9][0-9]*)$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pred evaluateWithObject:self];
}

/**
 判断字符串是否是16进制数据
 
 @return YES:字符串是16进制数据，NO:不是
 */
- (BOOL)isHexString{
    if (!HCKBluetoothValidStr(self) || self.length != 2) {
        return NO;
    }
    NSString *lowSourceString = [self lowercaseString];
    NSArray *hexInfoArray = @[@"a",@"b",@"c",@"d",@"e",@"f"];
    NSString *highString = [lowSourceString substringWithRange:NSMakeRange(0, 1)];
    NSString *lowString = [lowSourceString substringWithRange:NSMakeRange(1, 1)];
    BOOL highHexFlag = NO;
    if ([highString isRealNumbers]) {
        highHexFlag = YES;
    }else{
        for (NSString *tempString in hexInfoArray) {
            if ([tempString isEqualToString:highString]) {
                highHexFlag = YES;
                break;
            }
        }
    }
    
    BOOL lowHexFlag = NO;
    if ([lowString isRealNumbers]) {
        lowHexFlag = YES;
    }else{
        for (NSString *tempString in hexInfoArray) {
            if ([tempString isEqualToString:lowString]) {
                lowHexFlag = YES;
                break;
            }
        }
    }
    if (highHexFlag && lowHexFlag) {
        return YES;
    }
    return NO;
}

#pragma mark - Public method

/**
 判断当前字符串是否是mac地址
 
 @return YES:是mac地址，NO:不是mac地址
 */
- (BOOL)isMacAddress
{
    NSString *regex = @"([A-Fa-f0-9]{2}-){5}[A-Fa-f0-9]{2}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pred evaluateWithObject:self];
}

/**
 判断当时字符串是否是mac地址的其中四位
 
 @return YES,NO
 */
- (BOOL)isMacAddressLowFour{
    NSString *regex = @"([A-Fa-f0-9]{2}-){1}[A-Fa-f0-9]{2}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pred evaluateWithObject:self];
}

#pragma mark -
/**
 字符串转成相应的NSData数据
 
 @return 转换后的NSData
 */
- (NSData *)stringToData{
    if (!HCKBluetoothValidStr(self)) {
        return nil;
    }
    if (!(self.length % 2 == 0)) {
        //必须是偶数个字符才是合法的
        return nil;
    }
    Byte bytes[255] = {0};
    NSInteger count = 0;
    for (int i =0; i < self.length; i+=2) {
        NSString *strByte = [self substringWithRange:NSMakeRange(i,2)];
        unsigned long red = strtoul([strByte UTF8String],0,16);
        Byte b =  (Byte) ((0xff & red) );//( Byte) 0xff&iByte;
        bytes[i/2+0] = b;
        count ++;
    }
    NSData * data = [NSData dataWithBytes:bytes length:count];
    return data;
}
/**
 *  将二进制数据转换成十六进制字符串
 *
 *  @param sourceData 二进制数据
 *
 *  @return 十六进制字符串
 */
+ (NSString *)hexStringFromData:(NSData *)sourceData{
    if (!HCKBluetoothValidData(sourceData)) {
        return nil;
    }
    Byte *bytes = (Byte *)[sourceData bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[sourceData length];i++)
        
        {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
        }
    
    return hexStr;
}


/**
 将一个字节的16进制数据转成8位2进制
 
 @param hex 需要转换的16进制数据
 @return 转换后的8位2进制数据
 */
+ (NSString *)getBinaryByhex:(NSString *)hex{
    if (!HCKBluetoothValidStr(hex) || hex.length != 2 || ![hex isHexString]) {
        return nil;
    }
    NSDictionary *hexDic = @{
                             @"0":@"0000",@"1":@"0001",@"2":@"0010",
                             @"3":@"0011",@"4":@"0100",@"5":@"0101",
                             @"6":@"0110",@"7":@"0111",@"8":@"1000",
                             @"9":@"1001",@"A":@"1010",@"a":@"1010",
                             @"B":@"1011",@"b":@"1011",@"C":@"1100",
                             @"c":@"1100",@"D":@"1101",@"d":@"1101",
                             @"E":@"1110",@"e":@"1110",@"F":@"1111",
                             @"f":@"1111",
                             };
    NSString *binaryString = @"";
    for (int i=0; i<[hex length]; i++) {
        NSRange rage;
        rage.length = 1;
        rage.location = i;
        NSString *key = [hex substringWithRange:rage];
        binaryString = [NSString stringWithFormat:@"%@%@",
                        binaryString,
                        [NSString stringWithFormat:@"%@",[hexDic objectForKey:key]]];
        
    }
    
    return binaryString;
}

/**
 根据传入的数组来确定一个字节的16进制数
 
 @param paramList 传入的数据必须是@[@"00",@"00",@"00",@"00",@"00",@"00",@"00",@"00"]
 @return 16进制数据
 */
+ (NSString *)getHexStringWithArray:(NSArray *)paramList{
    if (!HCKBluetoothValidArray(paramList) || [paramList count] != 8) {
        return @"00";
    }
    unsigned long byteValue = 0;
    if ([paramList[0] isEqualToString:@"01"]) {
        byteValue |= 0x01;
    }
    if ([paramList[1] isEqualToString:@"01"]) {
        byteValue |= 0x02;
    }
    if ([paramList[2] isEqualToString:@"01"]) {
        byteValue |= 0x04;
    }
    if ([paramList[3] isEqualToString:@"01"]) {
        byteValue |= 0x08;
    }
    if ([paramList[4] isEqualToString:@"01"]) {
        byteValue |= 0x10;
    }
    if ([paramList[5] isEqualToString:@"01"]) {
        byteValue |= 0x20;
    }
    if ([paramList[6] isEqualToString:@"01"]) {
        byteValue |= 0x40;
    }
    if ([paramList[7] isEqualToString:@"01"]) {
        byteValue |= 0x80;
    }
    NSString *byteHexString = [NSString stringWithFormat:@"%1lx",byteValue];
    if (byteHexString.length == 1) {
        byteHexString = [@"0" stringByAppendingString:byteHexString];
    }
    return byteHexString;
}

/**
 根据闹钟类型转换成相应的手环相应数据
 
 @param type 闹钟类型
 @return 手环识别的16进制数据
 */
+ (NSString *)getAlarmClockTypeInfo:(alarmClockType)type{
    if (type == alarmClockDrink){
        return @"01";
    }else if (type == alarmClockMedicine){
        return @"00";
    }else if (type == alarmClockSleep){
        return @"04";
    }else if (type == alarmClockExcise){
        return @"05";
    }else if (type == alarmClockSport){
        return @"06";
    }
    return @"03";
}

/**
 根据传入的闹钟开启时间设定数据来返回手环识别的16进账数据
 
 @param clockSettings 闹钟开启和关闭的日期(周一至周日)数组，依次为周一至周日，相应位置@"01"代表开启，@"00"代表关闭，@[@"00",@"00",@"00",@"00",@"00",@"00",@"00"]代表周一至周日全部关闭，@[@"01",@"01",@"01",@"01",@"01",@"01",@"01"]代表周一至周日全部开启
 @return 手环识别的16进制数据
 */
+ (NSString *)getAlarmClockSettings:(NSArray *)clockSettings{
    NSString *setting = @"00";
    if ([clockSettings isKindOfClass:[NSArray class]] && [clockSettings count] == 7) {
        NSMutableArray *tempSettings = [NSMutableArray arrayWithArray:clockSettings];
        [tempSettings addObject:@"01"];
        setting = [self getHexStringWithArray:tempSettings];
    }
    return setting;
}

@end
