//
//  CBPeripheral+HCKAdditionalInfo.h
//  BluetoothDemo
//
//  Created by aa on 17/4/18.
//  Copyright © 2017年 HCK. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>

@interface CBPeripheral (HCKAdditionalInfo)

/**
 设备名字
 */
@property (nonatomic, copy) NSString *ls_advLocalName;

/**
 设备mac地址的低4位
 */
@property (nonatomic, copy) NSString *ls_advLocalMacLow;

/**
 设备完整的mac地址
 */
@property (nonatomic, copy) NSString *ls_advLocalMacName;

/**
 当前设备的信号值
 */
@property (nonatomic, strong, readonly)NSNumber *RSSIValue;

/**
 发送命令给外设的特征
 */
@property (nonatomic, strong)CBCharacteristic *writeCharacteristic;

/**
 读取外设数据的特征
 */
@property (nonatomic, strong)CBCharacteristic *readCharacteristic;


/**
 根据RSSI和广播的数据来设置设备的信号强度、MAC地址、MAC低四位、设备名称

 @param advertisementData 外设广播的数据
 @param RSSI 扫描到的外设的信号值强度
 */
- (void)configLs_advLocalInfomation:(NSDictionary *)advertisementData
                               RSSI:(NSNumber *)RSSI;

@end
