//
//  HCKConnectionStatusMonitoringManager.m
//  BluetoothDemo
//
//  Created by aa on 17/4/20.
//  Copyright © 2017年 HCK. All rights reserved.
//

#import "HCKConnectionStatusMonitoringManager.h"
#import "HCKPeripheralManager.h"
#import "HCKCentralManager.h"

static HCKConnectionStatusMonitoringManager *statusMonitoringManager = nil;

@interface HCKConnectionStatusMonitoringManager ()

/**
 中心外设之间连接状态改变时的回调
 */
@property (nonatomic, copy)HCKConnectStatusChangedBlock peripheralStatusChangedBlock;

/**
 中心蓝牙状态改变
 */
@property (nonatomic, copy)HCKCentralManagerStatusChangedBlock centralManagerStatusChangedBlock;

@end

@implementation HCKConnectionStatusMonitoringManager

#pragma mark - life circle

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:HCKCentralManagerStartConnectPeripheralNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:HCKCentralManagerConnectSuccessNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:HCKCentralManagerConnectFailedNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:HCKCentralManagerDisconnectPeripheralNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:HCKCentralManagerBluetoothStateChangedNotification
                                                  object:nil];
}

- (instancetype)init{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(startConnectPeripheral)
                                                     name:HCKCentralManagerStartConnectPeripheralNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(connectPeripheralSuccess)
                                                     name:HCKCentralManagerConnectSuccessNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(connectPeripheralFailed)
                                                     name:HCKCentralManagerConnectFailedNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(peripheralDisconnect)
                                                     name:HCKCentralManagerDisconnectPeripheralNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(centralManagerStateChanged)
                                                     name:HCKCentralManagerBluetoothStateChangedNotification
                                                   object:nil];
    }
    return self;
}

+ (HCKConnectionStatusMonitoringManager *)sharedStatusMonitoringManger{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!statusMonitoringManager) {
            statusMonitoringManager = [HCKConnectionStatusMonitoringManager new];
        }
    });
    return statusMonitoringManager;
}

#pragma mark - Private Method

/**
 中心开始连接外设
 */
-(void)startConnectPeripheral{
    if (self.peripheralStatusChangedBlock) {
        dispatch_main_async_safe(^{
            self.peripheralStatusChangedBlock(HCKPeripheralConnectStatusConnecting);
        });
    }
}

/**
 中心连接外设成功
 */
- (void)connectPeripheralSuccess{
    if (self.peripheralStatusChangedBlock) {
        dispatch_main_async_safe(^{
            self.peripheralStatusChangedBlock(HCKPeripheralConnectStatusConnected);
        });
    }
}

/**
 中心连接外设失败
 */
- (void)connectPeripheralFailed{
    if (self.peripheralStatusChangedBlock) {
        dispatch_main_async_safe(^{
            self.peripheralStatusChangedBlock(HCKPeripheralConnectStatusConnectedFailed);
        });
    }
}

/**
 中心外设断开连接
 */
- (void)peripheralDisconnect{
    if (self.peripheralStatusChangedBlock) {
        dispatch_main_async_safe(^{
            self.peripheralStatusChangedBlock(HCKPeripheralConnectStatusDisconnect);
        });
    }
}

/**
 中心蓝牙状态发生改变
 */
- (void)centralManagerStateChanged{
    if (!self.centralManagerStatusChangedBlock) {
        return;
    }
    dispatch_main_async_safe(^{
        HCKCentralManager *manager = [HCKCentralManager sharedCentralManager];
        if (manager.centralManager.state == CBCentralManagerStatePoweredOn) {
            //蓝牙可用
            self.centralManagerStatusChangedBlock(HCKCentralManagerStateEnable);
        }else if (manager.centralManager.state == CBCentralManagerStatePoweredOff){
            //蓝牙关闭
            self.centralManagerStatusChangedBlock(HCKCentralManagerStateUnable);
        }else{
            //未知状态
            self.centralManagerStatusChangedBlock(HCKCentralManagerStateUnknow);
        }
    });
}

#pragma mark - Public Method
/**
 监测当前外设连接状况
 
 @param statusBlock 当前外设连接状态回调
 */
- (void)startMonitoringConnectStatus:(HCKConnectStatusChangedBlock)statusBlock{
    if (!statusBlock) {
        return;
    }
    HCKPeripheralManager *perihperalManager = [HCKPeripheralManager sharedPeripheralManager];
    if (!perihperalManager.connectedPeripheral) {
        statusBlock(HCKPeripheralConnectStatusDisconnect);
    }else if (perihperalManager.connectedPeripheral.state == CBPeripheralStateDisconnected
              || perihperalManager.connectedPeripheral.state == CBPeripheralStateDisconnecting){
        statusBlock(HCKPeripheralConnectStatusDisconnect);
    }else if (perihperalManager.connectedPeripheral.state == CBPeripheralStateConnecting){
        statusBlock(HCKPeripheralConnectStatusConnecting);
    }else if (perihperalManager.connectedPeripheral.state == CBPeripheralStateConnected){
        statusBlock(HCKPeripheralConnectStatusConnected);
    }else{
        statusBlock(HCKPeripheralConnectStatusUnknow);
    }
    self.peripheralStatusChangedBlock = statusBlock;
}

/**
 当前中心与外设的连接状态
 */
- (HCKPeripheralConnectStatus)connectStatus{
    HCKPeripheralManager *perihperalManager = [HCKPeripheralManager sharedPeripheralManager];
    if (!perihperalManager.connectedPeripheral) {
        return HCKPeripheralConnectStatusUnknow;
    }else if (perihperalManager.connectedPeripheral.state == CBPeripheralStateDisconnected
              || perihperalManager.connectedPeripheral.state == CBPeripheralStateDisconnecting){
        return HCKPeripheralConnectStatusDisconnect;
    }else if (perihperalManager.connectedPeripheral.state == CBPeripheralStateConnecting){
        return HCKPeripheralConnectStatusConnecting;
    }else if (perihperalManager.connectedPeripheral.state == CBPeripheralStateConnected){
        return HCKPeripheralConnectStatusConnected;
    }
    return HCKPeripheralConnectStatusUnknow;
}

/**
 获取当前中心蓝牙状态

 @return 当前中心蓝牙状态
 */
- (HCKCentralManagerState)centralBluetoothStatus{
    HCKCentralManager *manager = [HCKCentralManager sharedCentralManager];
    if (manager.centralManager.state == CBCentralManagerStatePoweredOn) {
        //蓝牙可用
        return HCKCentralManagerStateEnable;
    }else if (manager.centralManager.state == CBCentralManagerStatePoweredOff){
        //蓝牙关闭
        return HCKCentralManagerStateUnable;
    }
    return HCKCentralManagerStateUnable;
}

/**
 监测当前中心的蓝牙状态
 
 @param statusBlock 当前中心蓝牙状态回调
 */
- (void)startMonitoringCentralManagerStatus:(HCKCentralManagerStatusChangedBlock)statusBlock{
    if (!statusBlock) {
        return;
    }
    HCKCentralManager *manager = [HCKCentralManager sharedCentralManager];
    if (manager.centralManager.state == CBCentralManagerStatePoweredOn) {
        //蓝牙可用
        statusBlock(HCKCentralManagerStateEnable);
    }else if (manager.centralManager.state == CBCentralManagerStatePoweredOff){
        //蓝牙关闭
        statusBlock(HCKCentralManagerStateUnable);
    }else{
        //未知状态
        statusBlock(HCKCentralManagerStateUnknow);
    }
    self.centralManagerStatusChangedBlock = statusBlock;
}

@end
