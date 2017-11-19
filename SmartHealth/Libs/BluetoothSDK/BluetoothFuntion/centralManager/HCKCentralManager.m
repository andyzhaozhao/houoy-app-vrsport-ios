//
//  HCKCentralManager.m
//  BluetoothDemo
//
//  Created by aa on 17/4/19.
//  Copyright © 2017年 HCK. All rights reserved.
//

#import "HCKCentralManager.h"
#import "HCKPeripheralManager.h"

static HCKCentralManager *sharedCentralManager = nil;
static NSInteger const defaultScanTime = 7;
static NSInteger const scanPeripheralCount = 2;

@interface HCKCentralManager ()<CBCentralManagerDelegate>

/**
 中心设备
 */
@property (nonatomic, strong)CBCentralManager *centralManager;

#pragma mark - 扫描

/**
 扫描定时器
 */
@property (nonatomic, strong)dispatch_source_t scanPeripheralTimer;

/**
 连接定时器，超过指定时间将会视为连接失败
 */
@property (nonatomic, strong)dispatch_source_t connectPeripheralTimer;

/**
 扫描到的设备列表
 */
@property (nonatomic, strong)NSMutableArray *peripheralList;

/**
 扫描结果Block
 */
@property (nonatomic, copy)HCKScanPeripheralResultBlock scanPeripheralResultBlock;

/**
 连接指定外设时候的外设特征值，mac地址、mac地址低四位、UUID都有可能，需要靠connectCharacteristicType区分
 */
@property (nonatomic, copy)NSString *targetPeripheralInfo;

/**
 当前manager的状态
 */
@property (nonatomic, assign)HCKCurrentManagerFunction currentManagerFunction;


#pragma mark - -------------------
/**
 连接外设成功Block
 */
@property (nonatomic, copy)HCKCentralManagerConnectPeripheralSuccessBlock connectSuccessBlock;

/**
 连接外设失败Block
 */
@property (nonatomic, copy)HCKCentralManagerConnectPeripheralFailedBlock connectFailedBlock;

/**
 扫描定时器是否处于超时状态
 */
@property (nonatomic, assign)BOOL timeOutFlag;

/**
 连接指定设备，超过设定时间(10s)视为连接失败
 */
@property (nonatomic, assign)BOOL connectTimeoutFlag;

/**
 连接设备的时候，需要多次扫描之后才会报超时
 */
@property (nonatomic, assign)NSInteger connectedScanCount;

@end

@implementation HCKCentralManager

#pragma mark - life circle

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:HCKCentralManagerConnectSuccessNotification
                                                  object:nil];
}

- (instancetype)init{
    if (self = [super init]) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self
                                                               queue:nil];
//        self.reconnect = YES;
        //注册连接设备成功(发现目标指定服务)取消连接定时器
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(connectPeripheralSuccess)
                                                     name:HCKCentralManagerConnectSuccessNotification
                                                   object:nil];
    }
    return self;
}

+ (HCKCentralManager *)sharedCentralManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!sharedCentralManager) {
            sharedCentralManager = [HCKCentralManager new];
        }
    });
    return sharedCentralManager;
}

#pragma mark - Delegate

#pragma mark ===================================中心代理===========================================
#pragma mark - CBCentralManagerDelegate
/**
 中心设备状态发生改变
 
 @param central 监测的中心设备
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    [[NSNotificationCenter defaultCenter] postNotificationName:HCKCentralManagerBluetoothStateChangedNotification
                                                        object:nil];
    if (central.state != CBCentralManagerStatePoweredOn) {
        //蓝牙不可用
        return;
    }
    //蓝牙处于打开状态且可用
}

/**
 当central扫描到了一个新的peripheral时调用
 
 @param central 当前CBCentralManager
 @param peripheral 扫描到的外设
 @param advertisementData 外设广播出来的数据
 @param RSSI 当前外设的信号值强度
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    [peripheral configLs_advLocalInfomation:advertisementData RSSI:RSSI];
    [self.peripheralList addObject:peripheral];
    NSLog(@"扫描到的设备广播数据:%@",advertisementData);
    //日志监测
    if (needCommunicationLog) {
        NSString *tempWriteString1 = [NSString stringWithFormat:@"扫描到的设备名字:%@",
                                     peripheral.ls_advLocalName];
        NSString *tempWriteString2 = [NSString stringWithFormat:@"设备UUID:%@",
                                      peripheral.identifier.UUIDString];
        NSString *tempWriteString3 = [NSString stringWithFormat:@"设备MAC地址:%@",
                                      peripheral.ls_advLocalMacName];
        [HCKLogFileManager writeCommandToLocalFile:@[tempWriteString1,tempWriteString2,tempWriteString3]
                                 withSourceInfo:HCKLocalDataSourceAPP];
    }
    if (!HCKBluetoothValidStr(self.targetPeripheralInfo)) {
        return;
    }
    if (self.currentManagerFunction == HCKCurrentManagerFunctionScan
        || self.timeOutFlag || self.connectedScanCount >= scanPeripheralCount) {
        return;
    }
    if (self.currentManagerFunction == HCKCurrentManagerFunctionConnectPeriphearlWithUUID
        && [peripheral.identifier.UUIDString isEqualToString:self.targetPeripheralInfo]) {
        //通过UUID连接设备
        [self centralManagerConnectPeripheral:peripheral];
    }else if (self.currentManagerFunction == HCKCurrentManagerFunctionConnectPeriphearlWithMAC
              && HCKBluetoothValidStr(peripheral.ls_advLocalMacName)
              && [peripheral.ls_advLocalMacName isEqualToString:self.targetPeripheralInfo]){
        //通过mac地址连接设备
        [self centralManagerConnectPeripheral:peripheral];
    }else if (self.currentManagerFunction == HCKCurrentManagerFunctionConnectPeriphearlWithMACLowFour
              && HCKBluetoothValidStr(peripheral.ls_advLocalMacLow)
              && [peripheral.ls_advLocalMacLow isEqualToString:self.targetPeripheralInfo]){
        //通过mac地址低四位连接设备
        [self centralManagerConnectPeripheral:peripheral];
    }
}

/**
 当与peripheral成功建立连接时调用
 
 @param central 当前CBCentralManager
 @param peripheral 已连接的设备
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    if (self.currentManagerFunction == HCKCurrentManagerFunctionScan) {
        //扫描状态
        return;
    }
    if (self.scanPeripheralTimer) {
        dispatch_cancel(self.scanPeripheralTimer);
    }
    self.timeOutFlag = NO;
    if (self.connectTimeoutFlag) {
        self.connectTimeoutFlag = NO;
        if (self.connectFailedBlock) {
            NSError *failedError = [[NSError alloc] initWithDomain:HCKCustomErrorDomain
                                                              code:customErrorCodeConnectedFailed
                                                          userInfo:@{@"errorInfo":@"device connection timeout"}];
            self.connectFailedBlock(failedError);
        }
        return;
    }
    HCKPeripheralManager *manager = [HCKPeripheralManager sharedPeripheralManager];
    manager.connectedPeripheral = peripheral;
    [manager HCKPeripheralManagerDiscoverServices:nil
                                     successBlock:self.connectSuccessBlock
                                      failedBlock:self.connectFailedBlock];
}

/**
 当central管理者与peripheral建立连接失败时调用。
 
 @param central 当前CBCentralManager
 @param peripheral 连接出错的目标设备
 @param error 错误信息
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    [[NSNotificationCenter defaultCenter] postNotificationName:HCKCentralManagerConnectFailedNotification
                                                        object:nil
                                                      userInfo:nil];
    if (self.currentManagerFunction == HCKCurrentManagerFunctionScan) {
        return;
    }
    if (self.connectPeripheralTimer) {
        dispatch_cancel(self.connectPeripheralTimer);
    }
    self.connectTimeoutFlag = NO;
    HCKPeripheralManager *manager = [HCKPeripheralManager sharedPeripheralManager];
    manager.connectedPeripheral = nil;
    if (self.connectFailedBlock) {
        dispatch_main_async_safe(^{
            NSError *failedError = [[NSError alloc] initWithDomain:HCKCustomErrorDomain
                                                              code:customErrorCodeConnectedFailed
                                                          userInfo:@{@"errorInfo":error.localizedDescription}];
            self.connectFailedBlock(failedError);
        });
    }
}

/**
 当已经与peripheral建立的连接断开时调用。
 
 @param central 当前CBCentralManager
 @param peripheral 断开连接的外设
 @param error 错误信息
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"断开连接");
    [[NSNotificationCenter defaultCenter] postNotificationName:HCKCentralManagerDisconnectPeripheralNotification
                                                        object:nil
                                                      userInfo:nil];
//    if (self.connectPeripheralTimer) {
//        dispatch_cancel(self.connectPeripheralTimer);
//    }
//    if (self.reconnect && self.centralManager.state == CBCentralManagerStatePoweredOn) {
//        //设置了设备断开连接的时候需要重新连接
//        [self centralManagerConnectPeripheral:peripheral];
//    }
}

#pragma mark - Public Method
/**
 扫描外部设备
 
 @param time 设置的扫描超时时间
 @param scanResultBlock 扫描结果Block
 */
- (void)scanPeripheralsWithScanTime:(NSInteger)time
          scanPeripheralResultBlock:(HCKScanPeripheralResultBlock)scanResultBlock{
    NSAssert(scanResultBlock != nil, @"If you want to scan the peripheral Bluetooth device, the scanResultBlock can not be nil");
    if (self.centralManager.state != CBCentralManagerStatePoweredOn) {
        //蓝牙状态不可用
        if (scanResultBlock) {
            dispatch_main_async_safe(^{
                NSError *error = [[NSError alloc] initWithDomain:HCKCustomErrorDomain
                                                            code:customErrorCodeBlueUnuseable
                                                        userInfo:@{@"errorInfo":@"mobile phone bluetooth is currently unavailable"}];
                scanResultBlock(error, nil);
            });
        }
        return;
    }
    HCKPeripheralManager *manager = [HCKPeripheralManager sharedPeripheralManager];
    if (manager.connectedPeripheral) {
        //开始扫描则需要保证当前中心设备没有连接任何的设备
        if (scanResultBlock) {
            dispatch_main_async_safe(^{
                NSError *error = [[NSError alloc] initWithDomain:HCKCustomErrorDomain
                                                            code:customErrorCodePeripheralConnectedAlready
                                                        userInfo:@{@"errorInfo":@"There is already a connected or being connected device, please first disconnect or cancel it"}];
                scanResultBlock(error, nil);
            });
        }
        return;
    }
    if ([self.centralManager isScanning]) {
        [self stopScan];
    }
    //日志监测
    if (needCommunicationLog) {
        [HCKLogFileManager writeCommandToLocalFile:@[@"开始扫描"]
                                 withSourceInfo:HCKLocalDataSourceAPP];
    }
    
    self.connectFailedBlock = nil;
    self.connectSuccessBlock = nil;
    //当前处于扫描状态
    self.currentManagerFunction = HCKCurrentManagerFunctionScan;
    //移除所有扫描到的设备
    [self.peripheralList removeAllObjects];
    self.scanPeripheralResultBlock = scanResultBlock;
    //开始扫描的通知
    [[NSNotificationCenter defaultCenter] postNotificationName:HCKCentralManagerStartScanNotification
                                                        object:nil
                                                      userInfo:nil];
    //最小扫描时间7S
    [self initScanTimer:MAX(time, defaultScanTime)];
    [self.centralManager scanForPeripheralsWithServices:nil
                                                options:nil];
}

/**
 外部通过UUID连接指定设备方法
 
 @param UUID 要连接的设备UUID
 @param connectSuccessBlock 连接成功回调
 @param connectFailedBlock 连接失败回调
 */
- (void)connectPeripheralWithUUID:(NSString *)UUID
              connectSuccessBlock:(HCKCentralManagerConnectPeripheralSuccessBlock)connectSuccessBlock
               connectFailedBlock:(HCKCentralManagerConnectPeripheralFailedBlock)connectFailedBlock{
    NSAssert(connectSuccessBlock != nil, @"If you want to connect the peripheral Bluetooth device, the connectSuccessBlock can not be nil");
    if (!HCKBluetoothValidStr(UUID)) {
        if (connectFailedBlock) {
            dispatch_main_async_safe(^{
                NSError *error = [[NSError alloc] initWithDomain:HCKCustomErrorDomain
                                                            code:customErrorCodeMacError
                                                        userInfo:@{@"errorInfo":@"Target device UUID can not be nil"}];
                connectFailedBlock(error);
            });
        }
        return;
    }
    [self connectPeripheralWithIdentifier:UUID
                          connectFunction:HCKCurrentManagerFunctionConnectPeriphearlWithUUID
                      connectSuccessBlock:connectSuccessBlock
                         connectFailBlock:connectFailedBlock];
}

/**
 通过mac地址连接指定设备，这个mac必须由外设广播出来，否则不能连接
 
 @param MAC 要连接外设的MAC地址
 @param connectSuccessBlock 连接成功回调
 @param connectFailedBlock  连接失败回调
 */
- (void)connectPeripheralWithMacInfo:(NSString *)MAC
                 connectSuccessBlock:(HCKCentralManagerConnectPeripheralSuccessBlock)connectSuccessBlock
                  connectFailedBlock:(HCKCentralManagerConnectPeripheralFailedBlock)connectFailedBlock{
    NSAssert(connectSuccessBlock != nil, @"If you want to connect the peripheral Bluetooth device, the connectSuccessBlock can not be nil");
    if (!HCKBluetoothValidStr(MAC)) {
        if (connectFailedBlock) {
            dispatch_main_async_safe(^{
                NSError *error = [[NSError alloc] initWithDomain:HCKCustomErrorDomain
                                                            code:customErrorCodeMacError
                                                        userInfo:@{@"errorInfo":@"Target device MAC address can not be nil"}];
                connectFailedBlock(error);
            });
        }
        return;
    }
    if (![MAC isMacAddress]) {
        if (connectFailedBlock) {
            dispatch_main_async_safe(^{
                NSError *error = [[NSError alloc] initWithDomain:HCKCustomErrorDomain
                                                            code:customErrorCodeMacError
                                                        userInfo:@{@"errorInfo":@"Target device MAC address is not in conformity with the rules"}];
                connectFailedBlock(error);
            });
        }
        return;
    }
    [self connectPeripheralWithIdentifier:[MAC lowercaseString]
                          connectFunction:HCKCurrentManagerFunctionConnectPeriphearlWithMAC
                      connectSuccessBlock:connectSuccessBlock
                         connectFailBlock:connectFailedBlock];
}

/**
 通过mac地址的低四位连接制定设备，这个mac地址必须由外设广播出来
 
 @param MACLow mac地址低四位
 @param connectSuccessBlock 连接成功回调
 @param connectFailedBlock 连接失败回调
 */
- (void)connectPeripheralWithMacLowFour:(NSString *)MACLow
                    connectSuccessBlock:(HCKCentralManagerConnectPeripheralSuccessBlock)connectSuccessBlock
                     connectFailedBlock:(HCKCentralManagerConnectPeripheralFailedBlock)connectFailedBlock{
    NSAssert(connectSuccessBlock != nil, @"If you want to connect the peripheral Bluetooth device, the connectSuccessBlock can not be nil");
    if (!HCKBluetoothValidStr(MACLow)) {
        if (connectFailedBlock) {
            dispatch_main_async_safe(^{
                NSError *error = [[NSError alloc] initWithDomain:HCKCustomErrorDomain
                                                            code:customErrorCodeMacError
                                                        userInfo:@{@"errorInfo":@"Target device MAC address low four number can not be nil"}];
                connectFailedBlock(error);
            });
        }
        return;
    }
    if (![MACLow isMacAddressLowFour]) {
        if (connectFailedBlock) {
            dispatch_main_async_safe(^{
                NSError *error = [[NSError alloc] initWithDomain:HCKCustomErrorDomain
                                                            code:customErrorCodeMacError
                                                        userInfo:@{@"errorInfo":@"Target device MAC adress low four number is not in conformity with rules"}];
                connectFailedBlock(error);
            });
        }
        return;
    }
    NSArray *tempMacArr = [MACLow componentsSeparatedByString:@"-"];
    NSString *macString = @"";
    if (HCKBluetoothValidArray(tempMacArr)) {
        for (NSString *tempString in tempMacArr) {
            macString = [macString stringByAppendingString:tempString];
        }
    }
    if (!HCKBluetoothValidStr(macString)) {
        if (connectFailedBlock) {
            dispatch_main_async_safe(^{
                NSError *error = [[NSError alloc] initWithDomain:HCKCustomErrorDomain
                                                            code:customErrorCodeMacError
                                                        userInfo:@{@"errorInfo":@"Target device MAC adress low four number transformation error"}];
                connectFailedBlock(error);
            });
        }
        return;
    }
    [self connectPeripheralWithIdentifier:[macString lowercaseString]
                          connectFunction:HCKCurrentManagerFunctionConnectPeriphearlWithMACLowFour
                      connectSuccessBlock:connectSuccessBlock
                         connectFailBlock:connectFailedBlock];
}

/**
 连接设备，当手环打开了ancs协议并且连接上了手机，这个时候只能通过指定设备来连接手环
 
 @param peripheral 指定连接的设备
 @param connectSuccessBlock 连接成功回调
 @param connectFailedBlock 连接失败回调
 */
- (void)connectPeripheral:(CBPeripheral *)peripheral
      connectSuccessBlock:(HCKCentralManagerConnectPeripheralSuccessBlock)connectSuccessBlock
       connectFailedBlock:(HCKCentralManagerConnectPeripheralFailedBlock)connectFailedBlock{
    NSAssert(connectSuccessBlock != nil, @"If you want to connect the peripheral Bluetooth device, the connectSuccessBlock can not be nil");
    if (self.centralManager.state != CBCentralManagerStatePoweredOn) {
        //蓝牙状态不可用
        if (connectFailedBlock) {
            dispatch_main_async_safe(^{
                NSError *error = [[NSError alloc] initWithDomain:HCKCustomErrorDomain
                                                            code:customErrorCodeBlueUnuseable
                                                        userInfo:@{@"errorInfo":@"mobile phone bluetooth is currently unavailable"}];
                connectFailedBlock(error);
            });
        }
        return;
    }
    if (!peripheral) {
        if (connectFailedBlock) {
            dispatch_main_async_safe(^{
                NSError *error = [[NSError alloc] initWithDomain:HCKCustomErrorDomain
                                                            code:customErrorCodeMacError
                                                        userInfo:@{@"errorInfo":@"Target device does not exist"}];
                connectFailedBlock(error);
            });
        }
        return;
    }
    HCKPeripheralManager *manager = [HCKPeripheralManager sharedPeripheralManager];
    if (manager.connectedPeripheral
        && (manager.connectedPeripheral.state == CBPeripheralStateConnected
            || manager.connectedPeripheral.state == CBPeripheralStateConnecting)) {
            if (connectFailedBlock) {
                dispatch_main_async_safe(^{
                    NSError *error = [[NSError alloc] initWithDomain:HCKCustomErrorDomain
                                                                code:customErrorCodePeripheralConnectedAlready
                                                            userInfo:@{@"errorInfo":@"There is already a connected or being connected device, please first disconnect or cancel it"}];
                    connectFailedBlock(error);
                });
            }
            return;
        }
    manager.connectedPeripheral = nil;
    if ([self.centralManager isScanning]) {
        [self stopScan];
    }
    manager.connectedPeripheral = peripheral;
    //日志监测
    if (needCommunicationLog) {
        [HCKLogFileManager writeCommandToLocalFile:@[@"开始通过指定设备连接"]
                                 withSourceInfo:HCKLocalDataSourceAPP];
    }
    self.currentManagerFunction = HCKCurrentManagerFunctionConnectPeripheralWithPeripheral;
    //移除所有扫描到的设备
    [self.peripheralList removeAllObjects];
    self.connectSuccessBlock = connectSuccessBlock;
    self.connectFailedBlock = connectFailedBlock;
    [self centralManagerConnectPeripheral:peripheral];
}

/**
 断开当前连接的外设
 */
- (void)disconnectConnectedPeripheral{
    HCKPeripheralManager *manager = [HCKPeripheralManager sharedPeripheralManager];
    
    if (!manager.connectedPeripheral) {
        return;
    }
    [self.centralManager cancelPeripheralConnection:manager.connectedPeripheral];
    manager.connectedPeripheral = nil;
    self.connectSuccessBlock = nil;
    self.connectFailedBlock = nil;
}

/**
 停止扫描
 */
- (void)stopScan{
    if (self.scanPeripheralTimer) {
        dispatch_cancel(self.scanPeripheralTimer);
    }
    [self.centralManager stopScan];
    self.scanPeripheralResultBlock = nil;
    self.timeOutFlag = NO;
}

#pragma mark - Private Method

/**
 中心连接指定外设
 
 @param peripheral 需要连接的外部设备
 */
- (void)centralManagerConnectPeripheral:(CBPeripheral *)peripheral{
    if (self.centralManager.state != CBCentralManagerStatePoweredOn) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:HCKCentralManagerStartConnectPeripheralNotification
                                                        object:nil
                                                      userInfo:nil];
    [self stopScan];
    if (self.scanPeripheralTimer) {
        dispatch_cancel(self.scanPeripheralTimer);
    }
    self.connectedScanCount = 0;
    //开启连接定时器，
    [self initConnectTimer];
    
    [self.centralManager connectPeripheral:peripheral
                                   options:@{}];
}

/**
 根据标识符和连接方式来连接指定的外设

 @param identifier 要连接外设的标识符
 @param fuction 连接方式
 @param successBlock 连接设备成功回调
 @param failedBlock 连接设备失败回调
 */
- (void)connectPeripheralWithIdentifier:(NSString *)identifier
                        connectFunction:(HCKCurrentManagerFunction)fuction
                    connectSuccessBlock:(HCKCentralManagerConnectPeripheralSuccessBlock)successBlock
                       connectFailBlock:(HCKCentralManagerConnectPeripheralFailedBlock)failedBlock{
    if (self.centralManager.state != CBCentralManagerStatePoweredOn) {
        //蓝牙状态不可用
        if (failedBlock) {
            dispatch_main_async_safe(^{
                NSError *error = [[NSError alloc] initWithDomain:HCKCustomErrorDomain
                                                            code:customErrorCodeBlueUnuseable
                                                        userInfo:@{@"errorInfo":@"mobile phone bluetooth is currently unavailable"}];
                failedBlock(error);
            });
        }
        return;
    }
    HCKPeripheralManager *manager = [HCKPeripheralManager sharedPeripheralManager];
    if (manager.connectedPeripheral
        && (manager.connectedPeripheral.state == CBPeripheralStateConnected
            || manager.connectedPeripheral.state == CBPeripheralStateConnecting)) {
            if (failedBlock) {
                dispatch_main_async_safe(^{
                    NSError *error = [[NSError alloc] initWithDomain:HCKCustomErrorDomain
                                                                code:customErrorCodePeripheralConnectedAlready
                                                            userInfo:@{@"errorInfo":@"There is already a connected or being connected device, please first disconnect or cancel it"}];
                    failedBlock(error);
                });
            }
            return;
        }
    manager.connectedPeripheral = nil;
    if ([self.centralManager isScanning]) {
        [self stopScan];
    }
    
    //日志监测
    if (needCommunicationLog) {
        NSString *tempWriteString = @"开始通过UUID连接设备";
        if (fuction == HCKCurrentManagerFunctionConnectPeriphearlWithMAC) {
            tempWriteString = @"开始通过MAC连接设备";
        }else if (fuction == HCKCurrentManagerFunctionConnectPeriphearlWithMACLowFour){
            tempWriteString = @"开始通过MAC低四位连接设备";
        }
        [HCKLogFileManager writeCommandToLocalFile:@[tempWriteString]
                                 withSourceInfo:HCKLocalDataSourceAPP];
    }
    
    self.currentManagerFunction = fuction;
    self.targetPeripheralInfo = identifier;
    //移除所有扫描到的设备
    [self.peripheralList removeAllObjects];
    self.connectSuccessBlock = successBlock;
    self.connectFailedBlock = failedBlock;
    [self initScanTimer:defaultScanTime];
    [self.centralManager scanForPeripheralsWithServices:nil
                                                options:nil];
}

#pragma mark - Timer Process
/**
 设置扫描设备的定时器，连接指定设备也是通过定时器扫描的
 
 @param timeOut 超时时间
 */
- (void)initScanTimer:(NSInteger)timeOut{
    self.timeOutFlag = NO;
    self.scanPeripheralTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,dispatch_get_global_queue(0, 0));
    //开始时间
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, timeOut * NSEC_PER_SEC);
    //间隔时间
    uint64_t interval = timeOut * NSEC_PER_SEC;
    dispatch_source_set_timer(self.scanPeripheralTimer, start, interval, 0);
    HCKBluetoothWS(weakSelf);
    //设置回调
    dispatch_source_set_event_handler(self.scanPeripheralTimer, ^{
        [weakSelf.centralManager stopScan];
        dispatch_cancel(weakSelf.scanPeripheralTimer);
        weakSelf.connectedScanCount ++;
        weakSelf.timeOutFlag = YES;
        
        if (!HCKBluetoothValidArray(weakSelf.peripheralList)
            && weakSelf.currentManagerFunction == HCKCurrentManagerFunctionScan) {
            weakSelf.connectedScanCount = 0;
            //日志监测
            if (needCommunicationLog) {
                [HCKLogFileManager writeCommandToLocalFile:@[@"没有扫描到设备"]
                                         withSourceInfo:HCKLocalDataSourceAPP];
            }
            //没有扫描到外围设备
            if (weakSelf.scanPeripheralResultBlock) {
                dispatch_main_async_safe(^{
                    NSError *error = [[NSError alloc] initWithDomain:HCKCustomErrorDomain
                                                                code:customErrorCodeScanPeripheralListEmpty
                                                            userInfo:@{@"errorInfo":@"No scanning to the device"}];
                    weakSelf.scanPeripheralResultBlock(error,nil);
                });
            }
            return ;
        }else if (!HCKBluetoothValidArray(weakSelf.peripheralList)
                  && weakSelf.currentManagerFunction != HCKCurrentManagerFunctionScan
                  && weakSelf.currentManagerFunction != HCKCurrentManagerFunctionConnectPeripheralWithPeripheral
                  && weakSelf.connectedScanCount == scanPeripheralCount){
            weakSelf.connectedScanCount = 0;
            //日志监测
            if (needCommunicationLog) {
                [HCKLogFileManager writeCommandToLocalFile:@[@"连接设备出错,没有扫描到周围的设备"]
                                         withSourceInfo:HCKLocalDataSourceAPP];
            }
            //连接状态下有效时间内没有扫描到目标设备
            if (weakSelf.connectFailedBlock) {
                dispatch_main_async_safe(^{
                    NSError *error = [[NSError alloc] initWithDomain:HCKCustomErrorDomain
                                                                code:customErrorCodeTimeOut
                                                            userInfo:@{@"errorInfo":@"Device connection error, no scanning to the surrounding equipment"}];
                    weakSelf.connectFailedBlock(error);
                });
            }
            return;
        }
        
        if (weakSelf.currentManagerFunction == HCKCurrentManagerFunctionScan
            && weakSelf.scanPeripheralResultBlock) {
            weakSelf.connectedScanCount = 0;
            //日志监测
            if (needCommunicationLog) {
                NSString *tempWriteString = [NSString stringWithFormat:@"扫描结束，共扫描到%ld个设备",
                                             (long)weakSelf.peripheralList.count];
                [HCKLogFileManager writeCommandToLocalFile:@[tempWriteString]
                                         withSourceInfo:HCKLocalDataSourceAPP];
            }
            //扫描状态
            dispatch_main_async_safe(^{
                weakSelf.scanPeripheralResultBlock(nil,[NSArray arrayWithArray:weakSelf.peripheralList]);
            });
            return;
        }else if (weakSelf.currentManagerFunction != HCKCurrentManagerFunctionScan
                  && weakSelf.currentManagerFunction != HCKCurrentManagerFunctionConnectPeripheralWithPeripheral
                  && weakSelf.connectFailedBlock
                  && weakSelf.connectedScanCount == scanPeripheralCount){
            weakSelf.connectedScanCount = 0;
            //日志监测
            if (needCommunicationLog) {
                [HCKLogFileManager writeCommandToLocalFile:@[@"没有扫描到要连接的设备"]
                                         withSourceInfo:HCKLocalDataSourceAPP];
            }
            //连接状态下有效时间内没有扫描到目标设备
            dispatch_main_async_safe(^{
                NSError *error = [[NSError alloc] initWithDomain:HCKCustomErrorDomain
                                                            code:customErrorCodeTimeOut
                                                        userInfo:@{@"errorInfo":@"Device connection error, no scanning to the specified equipment"}];
                weakSelf.connectFailedBlock(error);
            });
            return;
        }
        if (weakSelf.currentManagerFunction != HCKCurrentManagerFunctionScan
            && weakSelf.currentManagerFunction != HCKCurrentManagerFunctionConnectPeripheralWithPeripheral
            && weakSelf.connectedScanCount < scanPeripheralCount) {
            //日志监测
            if (needCommunicationLog) {
                [HCKLogFileManager writeCommandToLocalFile:@[@"重新扫描并连接设备"]
                                         withSourceInfo:HCKLocalDataSourceAPP];
            }
            //连接状态超时并且扫描次数在规定范围之后，需要重新扫描
            //移除所有扫描到的设备
            [weakSelf.peripheralList removeAllObjects];
            [weakSelf initScanTimer:defaultScanTime];
            [weakSelf.centralManager scanForPeripheralsWithServices:nil
                                                            options:nil];
        }
    });
    //启动timer
    dispatch_resume(self.scanPeripheralTimer);
}

/**
 连接定时器，当开始连接某个外设的时候，有可能产生连接超时的情况
 */
- (void)initConnectTimer{
    self.connectTimeoutFlag = NO;
    dispatch_queue_t connectQueue = dispatch_queue_create("connectPeripheralQueue", DISPATCH_QUEUE_CONCURRENT);
    self.connectPeripheralTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,connectQueue);
    //开始时间
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC);
    //间隔时间
    uint64_t interval = 10 * NSEC_PER_SEC;
    dispatch_source_set_timer(self.connectPeripheralTimer, start, interval, 0);
    HCKBluetoothWS(weakSelf);
    //设置回调
    dispatch_source_set_event_handler(self.connectPeripheralTimer, ^{
        dispatch_cancel(self.connectPeripheralTimer);
        weakSelf.connectTimeoutFlag = YES;
        if (self.connectFailedBlock) {
            if (self.connectFailedBlock) {
                dispatch_main_async_safe(^{
                    NSError *failedError = [[NSError alloc] initWithDomain:HCKCustomErrorDomain
                                                                      code:customErrorCodeConnectedFailed
                                                                  userInfo:@{@"errorInfo":@"device connection timeout"}];
                    self.connectFailedBlock(failedError);
                });
                
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:HCKCentralManagerConnectFailedNotification
                                                            object:nil];
        HCKPeripheralManager *manager = [HCKPeripheralManager sharedPeripheralManager];
        
        if (!manager.connectedPeripheral) {
            return;
        }
        [weakSelf.centralManager cancelPeripheralConnection:manager.connectedPeripheral];
        manager.connectedPeripheral = nil;
    });
    //启动timer
    dispatch_resume(self.connectPeripheralTimer);
}

- (void)connectPeripheralSuccess{
    dispatch_cancel(self.connectPeripheralTimer);
}

#pragma mark - setter & getter

- (NSMutableArray *)peripheralList{
    if (!_peripheralList) {
        _peripheralList = [NSMutableArray array];
    }
    return _peripheralList;
}

- (CBCentralManager *)centralManager{
    if (!_centralManager) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self
                                                               queue:nil];
    }
    return _centralManager;
}

@end
