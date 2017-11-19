//
//  HCKCentralManager.h
//  BluetoothDemo
//
//  Created by aa on 17/4/19.
//  Copyright © 2017年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "HCKBluetoothGlobal.h"

@interface HCKCentralManager : NSObject

/**
 连接的外设断开连接的时候，是否需要自动连接,默认YES
 */
@property (nonatomic, assign)BOOL reconnect;

/**
 中心设备
 */
@property (nonatomic, strong, readonly)CBCentralManager *centralManager;

#pragma mark - init Method
+ (HCKCentralManager *)sharedCentralManager;

/**
 扫描外部设备
 
 @param time 设置的扫描超时时间
 @param scanResultBlock 扫描结果Block
 */
- (void)scanPeripheralsWithScanTime:(NSInteger)time
          scanPeripheralResultBlock:(HCKScanPeripheralResultBlock)scanResultBlock;

/**
 外部通过UUID连接指定设备方法
 
 @param UUID 要连接的设备UUID
 @param connectSuccessBlock 连接成功回调
 @param connectFailedBlock 连接失败回调
 */
- (void)connectPeripheralWithUUID:(NSString *)UUID
              connectSuccessBlock:(HCKCentralManagerConnectPeripheralSuccessBlock)connectSuccessBlock
               connectFailedBlock:(HCKCentralManagerConnectPeripheralFailedBlock)connectFailedBlock;

/**
 通过mac地址连接指定设备，这个mac必须由外设广播出来，否则不能连接
 
 @param MAC 要连接外设的MAC地址
 @param connectSuccessBlock 连接成功回调
 @param connectFailedBlock  连接失败回调
 */
- (void)connectPeripheralWithMacInfo:(NSString *)MAC
                 connectSuccessBlock:(HCKCentralManagerConnectPeripheralSuccessBlock)connectSuccessBlock
                  connectFailedBlock:(HCKCentralManagerConnectPeripheralFailedBlock)connectFailedBlock;

/**
 通过mac地址的低四位连接制定设备，这个mac地址必须由外设广播出来
 
 @param MACLow mac地址低四位
 @param connectSuccessBlock 连接成功回调
 @param connectFailedBlock 连接失败回调
 */
- (void)connectPeripheralWithMacLowFour:(NSString *)MACLow
                    connectSuccessBlock:(HCKCentralManagerConnectPeripheralSuccessBlock)connectSuccessBlock
                     connectFailedBlock:(HCKCentralManagerConnectPeripheralFailedBlock)connectFailedBlock;


/**
 连接设备，当手环打开了ancs协议并且连接上了手机，这个时候只能通过指定设备来连接手环

 @param peripheral 指定连接的设备
 @param connectSuccessBlock 连接成功回调
 @param connectFailedBlock 连接失败回调
 */
- (void)connectPeripheral:(CBPeripheral *)peripheral
      connectSuccessBlock:(HCKCentralManagerConnectPeripheralSuccessBlock)connectSuccessBlock
       connectFailedBlock:(HCKCentralManagerConnectPeripheralFailedBlock)connectFailedBlock;

/**
 断开当前连接的外设
 */
- (void)disconnectConnectedPeripheral;

/**
 停止扫描
 */
- (void)stopScan;

@end
