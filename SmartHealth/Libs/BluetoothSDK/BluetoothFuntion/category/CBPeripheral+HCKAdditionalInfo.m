//
//  CBPeripheral+HCKAdditionalInfo.m
//  BluetoothDemo
//
//  Created by aa on 17/4/18.
//  Copyright © 2017年 HCK. All rights reserved.
//

#import "CBPeripheral+HCKAdditionalInfo.h"
#import <objc/runtime.h>
#import "HCKBluetoothGlobal.h"

static const char *HCK_AdvLocalNameKey = "LS_AdvLocalNameKey";
static const char *HCK_AdvMacLowKey = "HCK_AdvMacLowKey";
static const char *HCK_AdvMacNameKey = "HCK_AdvMacNameKey";
static const char *HCK_AdvRSSIKey = "HCK_AdvRSSIKey";
static const char *HCK_PeripheralWriteCBCharacteristicKey = "HCK_PeripheralWriteCBCharacteristicKey";
static const char *HCK_PeripheralReadCBCharacteristicKey = "HCK_PeripheralReadCBCharacteristicKey";

@implementation CBPeripheral (HCKAdditionalInfo)

#pragma mark - Public Method

/**
 根据手环广播的数据，获取到手环MAC地址的低4位

 @param ManufacturerData 手环的广播数据
 @return 手环MAC地址的低四位
 */
- (NSString *)getMacLowName:(NSString *)ManufacturerData{
    NSString *inputStr = nil;
    if ([ManufacturerData isKindOfClass:[NSString class]] &&
        ManufacturerData.length > 12) {
        inputStr = [ManufacturerData substringWithRange:NSMakeRange(10, 4)];
    }
    return inputStr;
}

/**
 截取广播数据里面的外设MAC地址

 @param ManufacturerData 外设广播的数据
 @return 截取到的MAC地址
 */
- (NSString *)getMacNameInfo:(NSString *)ManufacturerData{
    NSArray *tempArr = [ManufacturerData componentsSeparatedByString:@" "];
    if (!HCKBluetoothValidArray(tempArr)) {
        return nil;
    }
    NSString *tempProcessStr = @"";
    for (NSString *temp in tempArr) {
        tempProcessStr = [tempProcessStr stringByAppendingString:temp];
    }
    if (!HCKBluetoothValidStr(tempProcessStr)) {
        return nil;
    }
    NSString *macName = @"";
    if ([tempProcessStr isKindOfClass:[NSString class]] && tempProcessStr.length > 12) {
        for (NSInteger i = 0; i < 6; i ++) {
            NSString *tempStr = [tempProcessStr substringWithRange:NSMakeRange(i * 2 + 1, 2)];
            if (i != 0) {
                tempStr = [@"-" stringByAppendingString:tempStr];
            }
            macName = [macName stringByAppendingString:tempStr];
        }
    }
    return macName;
}

/**
 根据RSSI和广播的数据来设置设备的信号强度、MAC地址、MAC低四位、设备名称
 
 @param advertisementData 外设广播的数据
 @param RSSI 扫描到的外设的信号值强度
 */
- (void)configLs_advLocalInfomation:(NSDictionary *)advertisementData
                               RSSI:(NSNumber *)RSSI{
    if (HCKBluetoothValidNum(RSSI)) {
        [self setRSSIValue:RSSI];
    }
    if (!HCKBluetoothValidDict(advertisementData)) {
        return;
    }
    NSArray *keys = [advertisementData allKeys];
    if (!HCKBluetoothValidArray(keys)) {
        return;
    }
    for (int i = 0; i < [keys count]; ++i) {
        NSString *keyName = (NSString *) keys[i];
        id value = [advertisementData objectForKey:keyName];
        if (![value isKindOfClass: [NSArray class]] && HCKBluetoothValidStr(keyName)) {
            if ([keyName isEqualToString:@"kCBAdvDataLocalName"]) {
                [self setLs_advLocalName:[value description]];
            }else if ([keyName isEqualToString:@"kCBAdvDataManufacturerData"]){
                NSString *tempString = [[value description] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                [self setLs_advLocalMacLow:[[self getMacLowName:tempString] lowercaseString]];
                [self setLs_advLocalMacName:[[self getMacNameInfo:tempString] lowercaseString]];
            }
        }
        
    }
}

#pragma mark - setter & getter
- (void)setLs_advLocalName:(NSString *)ls_advLocalName{
    if (!HCKBluetoothValidStr(ls_advLocalName)) {
        return;
    }
    objc_setAssociatedObject(self, &HCK_AdvLocalNameKey, ls_advLocalName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)ls_advLocalName{
    return objc_getAssociatedObject(self, &HCK_AdvLocalNameKey);
}

- (void)setLs_advLocalMacLow:(NSString *)ls_advLocalMacLow{
    if (!HCKBluetoothValidStr(ls_advLocalMacLow)) {
        return;
    }
    objc_setAssociatedObject(self, &HCK_AdvMacLowKey, ls_advLocalMacLow, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)ls_advLocalMacLow{
    return objc_getAssociatedObject(self, &HCK_AdvMacLowKey);
}

- (void)setLs_advLocalMacName:(NSString *)ls_advLocalMacName{
    if (!HCKBluetoothValidStr(ls_advLocalMacName)) {
        return;
    }
    objc_setAssociatedObject(self, &HCK_AdvMacNameKey, ls_advLocalMacName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)ls_advLocalMacName{
    return objc_getAssociatedObject(self, &HCK_AdvMacNameKey);
}

- (void)setRSSIValue:(NSNumber *)RSSIValue{
    if (!HCKBluetoothValidNum(RSSIValue)) {
        return;
    }
    objc_setAssociatedObject(self, &HCK_AdvRSSIKey, RSSIValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)RSSIValue{
    return objc_getAssociatedObject(self, &HCK_AdvRSSIKey);
}

- (void)setWriteCharacteristic:(CBCharacteristic *)writeCharacteristic{
    if (!writeCharacteristic) {
        return;
    }
    objc_setAssociatedObject(self, &HCK_PeripheralWriteCBCharacteristicKey, writeCharacteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CBCharacteristic *)writeCharacteristic{
    return objc_getAssociatedObject(self, &HCK_PeripheralWriteCBCharacteristicKey);
}

- (void)setReadCharacteristic:(CBCharacteristic *)readCharacteristic{
    if (!readCharacteristic) {
        return;
    }
    objc_setAssociatedObject(self, &HCK_PeripheralReadCBCharacteristicKey, readCharacteristic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CBCharacteristic *)readCharacteristic{
    return objc_getAssociatedObject(self, &HCK_PeripheralReadCBCharacteristicKey);
}

@end
