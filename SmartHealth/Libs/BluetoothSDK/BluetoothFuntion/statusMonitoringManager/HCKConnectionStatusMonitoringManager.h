//
//  HCKConnectionStatusMonitoringManager.h
//  BluetoothDemo
//
//  Created by aa on 17/4/20.
//  Copyright © 2017年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HCKBluetoothGlobal.h"

@interface HCKConnectionStatusMonitoringManager : NSObject

/**
 当前中心与外设的连接状态
 */
@property (nonatomic, assign, readonly)HCKPeripheralConnectStatus connectStatus;

/**
 中心蓝牙状态
 */
@property (nonatomic, assign, readonly)HCKCentralManagerState centralBluetoothStatus;

+ (HCKConnectionStatusMonitoringManager *)sharedStatusMonitoringManger;

/**
 监测当前外设连接状况

 @param statusBlock 当前外设连接状态回调
 */
- (void)startMonitoringConnectStatus:(HCKConnectStatusChangedBlock)statusBlock;

/**
 监测当前中心的蓝牙状态

 @param statusBlock 当前中心蓝牙状态回调
 */
- (void)startMonitoringCentralManagerStatus:(HCKCentralManagerStatusChangedBlock)statusBlock;

@end
