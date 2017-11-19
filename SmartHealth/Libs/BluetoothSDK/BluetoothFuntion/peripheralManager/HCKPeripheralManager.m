//
//  HCKPeripheralManager.m
//  BluetoothDemo
//
//  Created by aa on 17/4/19.
//  Copyright © 2017年 HCK. All rights reserved.
//

#import "HCKPeripheralManager.h"
#import <objc/runtime.h>
#import "HCKCommunicationTask.h"
#import "HCKCommuDataConversionTool.h"
#import "HCKAlarmClockModel.h"

@interface HCKCommandCommuObj : NSObject<NSCopying,NSMutableCopying>

/**
 该条指令是否处于超时状态，YES超时，NO不超时
 */
@property (nonatomic, assign)BOOL timeOutStatus;

/**
 数据通信任务
 */
@property (nonatomic, strong)HCKCommunicationTask *task;

/**
 接收数据的定时器，超过设定时间内没有接收到数据，则结束掉任务，认为超时
 */
@property (nonatomic, strong)dispatch_source_t receiveTimer;

/**
 接收数据超时次数
 */
@property (nonatomic, assign)NSInteger timeoutCount;

/**
 数据通信成功Block
 */
@property (nonatomic, copy)HCKDataCommunicationSuccessBlock communicationSuccessBlock;

/**
 数据通信失败Block
 */
@property (nonatomic, copy)HCKDataCommunicationFailedBlock communicationFailedBlock;

/**
 本次请求手环返回的数据条数
 */
@property (nonatomic, assign)NSInteger respondDataNumber;

/**
 手环返回的数据，数组类型，对于请求手环数据的命令，手环返回多条数据才算是成功
 */
@property (nonatomic, strong)NSMutableArray *dataList;

@end

@implementation HCKCommandCommuObj

- (id)copyWithZone:(NSZone *)zone{
    HCKCommandCommuObj *copyModel = [[HCKCommandCommuObj allocWithZone:zone] init];
    copyModel.communicationFailedBlock = self.communicationFailedBlock;
    copyModel.communicationSuccessBlock = self.communicationSuccessBlock;
    return copyModel;
}

- (id)mutableCopyWithZone:(NSZone *)zone{
    HCKCommandCommuObj *mutableCopyModel = [[HCKCommandCommuObj allocWithZone:zone] init];
    mutableCopyModel.dataList = self.dataList;
    return mutableCopyModel;
}

- (NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

@end

@interface sleepDataModel : NSObject

/**
 睡眠index数据
 */
@property (nonatomic, strong)NSMutableArray *sleepIndexArray;

/**
 睡眠record数据
 */
@property (nonatomic, strong)NSMutableArray *sleepRecordArray;

@end

@implementation sleepDataModel


@end

static char *const HCKConnectedPeripheralKey = "HCKConnectedPeripheralKey";
static HCKPeripheralManager *sharedPeripheralManager = nil;
static NSTimeInterval defaultCommandTime = 3.0f;
static NSTimeInterval requestPeripheralDataTime = 6.0f;

static NSTimeInterval receiveTimeoutTime = 4.f;

#define canSendCommand (!self.connectedPeripheral\
                        || self.connectedPeripheral.state != CBPeripheralStateConnected)\
                        ? NO : YES\

#define connectError(block)\
if(block){\
dispatch_main_async_safe(^{\
    NSError *error = [[NSError alloc] initWithDomain:HCKCustomErrorDomain\
                                                code:customErrorCodePeripheralUnconnected\
                                            userInfo:@{@"errorInfo":@"The current connection device is in disconnect"}];\
    block(error);\
});\
}\

#define paramsError(block)\
if(block){\
dispatch_main_async_safe(^{\
    NSError *error = [[NSError alloc] initWithDomain:HCKCustomErrorDomain\
                                                code:customErrorCodeOptionsError\
                                            userInfo:@{@"errorInfo":@"input parameter error"}];\
    block(error);\
});\
}\

#define communicationTimeout(block)\
if(block){\
dispatch_main_async_safe(^{\
    NSError *error = [[NSError alloc] initWithDomain:HCKCustomErrorDomain\
                                                code:customErrorCodeCommunicationTimeOut\
                                            userInfo:@{@"errorInfo":@"Data communication timeout"}];\
    block(error);\
});\
}\

#define requestPeripheralDataError(block)\
if(block){\
    dispatch_main_async_safe(^{\
    NSError *error = [[NSError alloc] initWithDomain:HCKCustomErrorDomain\
                                                code:customErrorCodeRequestPeripheralDataError\
                                            userInfo:@{@"errorInfo":@"Request bracelet data error"}];\
        block(error);\
    });\
}\

@interface HCKPeripheralManager ()<CBPeripheralDelegate>

/**
 数据通信超时标志
 */
@property (nonatomic, assign)BOOL timeOutFlag;

/**
 连接设备成功Block
 */
@property (nonatomic, copy)HCKCentralManagerConnectPeripheralSuccessBlock connectSuccessBlock;

/**
 连接设备失败Block
 */
@property (nonatomic, copy)HCKCentralManagerConnectPeripheralFailedBlock connectFailedBlock;

/**
 数据通信对象字典
 */
@property (nonatomic, strong)NSMutableDictionary *communicationDic;

/**
 睡眠数据
 */
@property (nonatomic, strong)sleepDataModel *sleepModel;

@end

@implementation HCKPeripheralManager

#pragma mark - life circle

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:HCKCentralManagerDisconnectPeripheralNotification
                                                  object:nil];
}

- (instancetype)init{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(peripheralDisconnect)
                                                     name:HCKCentralManagerDisconnectPeripheralNotification
                                                   object:nil];
    }
    return self;
}

+ (HCKPeripheralManager *)sharedPeripheralManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!sharedPeripheralManager) {
            sharedPeripheralManager = [HCKPeripheralManager new];
        }
    });
    return sharedPeripheralManager;
}

#pragma mark ===================================外设代理===========================================
#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HCKCentralManagerConnectFailedNotification
                                                            object:nil
                                                          userInfo:nil];
        if (self.connectFailedBlock) {
            dispatch_main_async_safe(^{
                NSError *failedError = [[NSError alloc] initWithDomain:HCKCustomErrorDomain
                                                                  code:customErrorCodeConnectedFailed
                                                              userInfo:@{@"errorInfo":error.localizedDescription}];
                self.connectFailedBlock(failedError);
            });
        }
        return;
    }
    for (CBService *service in peripheral.services) {
        //发现服务
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"FFC0"]]) {
            [peripheral discoverCharacteristics:nil forService:service];
            break;
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HCKCentralManagerConnectFailedNotification
                                                            object:nil
                                                          userInfo:nil];
        if (self.connectFailedBlock) {
            dispatch_main_async_safe(^{
                NSError *failedError = [[NSError alloc] initWithDomain:HCKCustomErrorDomain
                                                                  code:customErrorCodeConnectedFailed
                                                              userInfo:@{@"errorInfo":error.localizedDescription}];
                self.connectFailedBlock(failedError);
            });
        }
        return;
    }
    if (!HCKBluetoothValidArray(service.characteristics)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HCKCentralManagerConnectFailedNotification
                                                            object:nil
                                                          userInfo:nil];
        if (self.connectFailedBlock) {
            dispatch_main_async_safe(^{
                NSError *failedError = [[NSError alloc] initWithDomain:HCKCustomErrorDomain
                                                                  code:customErrorCodeConnectedFailed
                                                              userInfo:@{@"errorInfo":@"Fail to find available service feature"}];
                self.connectFailedBlock(failedError);
            })
        }
        return;
    }
    [self readDataFromPeripheral];
    [self getPeripheralWritecharacteristic];
    if (needCommunicationLog) {
        NSString *tempWriteString1 = [NSString stringWithFormat:@"连接的设备名字:%@",
                                     peripheral.ls_advLocalName];
        NSString *tempWriteString2 = [NSString stringWithFormat:@"设备UUID:%@",
                                      peripheral.identifier.UUIDString];
        NSString *tempWriteString3 = [NSString stringWithFormat:@"设备MAC地址:%@",peripheral.ls_advLocalMacName];
        
        [HCKLogFileManager writeCommandToLocalFile:@[tempWriteString1,tempWriteString2,tempWriteString3]
                                 withSourceInfo:HCKLocalDataSourceAPP];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:HCKCentralManagerConnectSuccessNotification
                                                        object:nil
                                                      userInfo:nil];
    if (self.connectSuccessBlock) {
        dispatch_main_async_safe(^{
            self.connectSuccessBlock(self.connectedPeripheral,
                                     self.connectedPeripheral.identifier.UUIDString,
                                     self.connectedPeripheral.ls_advLocalMacName);
        });
    }
}

//- peripheral:didUpdateNotificationStateForCharacteristic:error:
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"read data from peripheral error:%@", [error localizedDescription]);
        return;
    }
    
    NSData *readData = characteristic.value;
    NSString *dataFromPeripheral = [NSString hexStringFromData:readData];
    if (dataFromPeripheral == nil
        || dataFromPeripheral.length < 3) {
        return;
    }
    HCKCommuDataConvModel *dataModel = [HCKCommuDataConversionTool communicationDataConvToModel:dataFromPeripheral];
    HCKCommandCommuObj *tempModel = self.communicationDic[bleStringFromInteger(dataModel.commandPostion)];
    if (!tempModel || !dataModel) {
        return ;
    }
    if (!tempModel.dataList) {
        tempModel.dataList = [NSMutableArray array];
    }
    if (!dataModel) {
        return;
    }
    
    if (dataModel.commandPostion == HCKCommuCommandPeripheralRequestHeartRate) {
        //如果是心率数据，由于手环返回的一条数据包含三条心率数据，所以在这个地方需要作出处理
        if (HCKBluetoothValidArray(dataModel.commuData)) {
            [tempModel.dataList addObjectsFromArray:dataModel.commuData];
        }
    }else{
        [tempModel.dataList addObject:dataModel.commuData];
    }
    
    [self processCommunicationObj:@(dataModel.commandPostion)
                          timeOut:@(0)];
}

#pragma mark - Private Method

/**
 当手环断开连接之后的处理
 */
- (void)peripheralDisconnect{
    self.connectedPeripheral = nil;
    NSArray *taskArray = [self.communicationDic allValues];
    if (!HCKBluetoothValidArray(taskArray)) {
        return;
    }
    //结束掉所有的任务
    for (HCKCommandCommuObj *tempModel in taskArray) {
        if (tempModel.task) {
            [tempModel.task cancle];
        }
        if (tempModel.receiveTimer) {
            dispatch_cancel(tempModel.receiveTimer);
        }
        HCKDataCommunicationFailedBlock tempFailedBlock = [tempModel.communicationFailedBlock copy];
        communicationTimeout(tempFailedBlock);
    }
    [self.communicationDic removeAllObjects];
}

/**
 根据当前命令转换成写日志时的字符串

 @return 写日志时的字符串
 */
- (NSString *)commandConversionToString:(HCKCommuCommandPostion)postion{
    if (postion == HCKCommuCommandPeripheralOpenANCS) {
        return @"开启ancs";
    }else if (postion == HCKCommuCommandPeripheralANCSNotice){
        return @"写ancs通知";
    }else if (postion == HCKCommuCommandPeripheralDateInfo){
        return @"同步当前日期";
    }else if (postion == HCKCommuCommandPeripheralPersonalInformation){
        return @"同步个人信息";
    }else if (postion == HCKCommuCommandPeripheralVibration){
        return @"手环震动";
    }else if (postion == HCKCommuCommandPeripheralUnit){
        return @"同步单位信息";
    }else if (postion == HCKCommuCommandPeripheralTimeFormat){
        return @"同步时间进制信息";
    }else if (postion == HCKCommuCommandPeripheralPalmingBrightScreen){
        return @"同步翻腕亮屏信息";
    }else if (postion == HCKCommuCommandPeripheralAlarmClockSetting){
        return @"同步闹钟信息";
    }else if (postion == HCKCommuCommandPeripheralLastScreenDisplay){
        return @"同步上次屏幕显示信息";
    }else if (postion == HCKCommuCommandPeripheralSedentaryRemind){
        return @"同步久坐提醒信息";
    }else if (postion == HCKCommuCommandPeripheralHeartRateAcquisitionInterval){
        return @"同步心率采集间隔信息";
    }else if (postion == HCKCommuCommandPeripheralScreenDisplay){
        return @"同步手环屏幕显示信息";
    }else if (postion == HCKCommuCommandPeripheralCloseANCS){
        return @"关闭手环ancs";
    }else if (postion == HCKCommuCommandPeripheralRequestMemoryData){
        return @"请求手环memory数据";
    }else if (postion == HCKCommuCommandPeripheralRequestStepData){
        return @"请求计步数据";
    }else if (postion == HCKCommuCommandPeripheralRequestTotalOfSleep){
        return @"请求睡眠总数";
    }else if (postion == HCKCommuCommandPeripheralRequestSleepIndex){
        return @"请求睡眠index";
    }else if (postion == HCKCommuCommandPeripheralRequestSleepRecord){
        return @"请求睡眠record";
    }else if (postion == HCKCommuCommandPeripheralRequestHeartRate){
        return @"请求心率数据";
    }else if (postion == HCKCommuCommandPeripheralRequestFirmwareVersion){
        return @"请求手环固件版本";
    }else if (postion == HCKCommuCommandPeripheralRequestInternalVersionNumber){
        return @"请求手环内部版本号";
    }
    return @"";
}

/**
 连接设备之后，获取该设备接受命令的特征
 */
- (void)getPeripheralWritecharacteristic{
    for (CBService *service in [self.connectedPeripheral.services mutableCopy]) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"FFC0"]]) {
            for (CBCharacteristic *characteristic in [service.characteristics mutableCopy]) {
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFC1"]]) {
                    self.connectedPeripheral.writeCharacteristic = characteristic;
                    break;
                }
            }
            break;
        }
    }
}

/**
 app--->device

 @param data 发送的数据
 @param commandPostion 哪条命令
 */
- (void)writeDataToPeripheral:(NSData *)data
           withCommandPostion:(HCKCommuCommandPostion)commandPostion
{
    if (needCommunicationLog) {
        //写监测日志
        NSString *tempWriteString = [NSString stringWithFormat:@"%@:%@",
                                     [self commandConversionToString:commandPostion],
                                     [NSString hexStringFromData:data]];
        [HCKLogFileManager writeCommandToLocalFile:@[tempWriteString]
                                 withSourceInfo:HCKLocalDataSourceAPP];
    }
    [self.connectedPeripheral writeValue:data
                       forCharacteristic:self.connectedPeripheral.writeCharacteristic
                                    type:CBCharacteristicWriteWithResponse];
}

/**
 device----->app
 */
- (void)readDataFromPeripheral
{
    for (CBService *service in [self.connectedPeripheral.services mutableCopy]) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"FFC0"]]) {
            for (CBCharacteristic *characteristic in [service.characteristics mutableCopy]) {
                if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFC2"]]) {
                    [self.connectedPeripheral setNotifyValue:YES
                                           forCharacteristic:characteristic];
                    self.connectedPeripheral.readCharacteristic = characteristic;
                    break;
                }
            }
            break;
        }
    }
}

/**
 给每一条指令初始化一个model，进行数据通信

 @param timeOut 该条指令数据通信的超时时间
 @param respondNumber 本次数据请求手环返回的数据个数
 @param start 是否启动任务
 @param commandPostion 该命令的类型
 @param successBlock 指令通信成功Block
 @param failedBlock 指令通信失败Block
 */
- (void)initCommunicationTimer:(NSTimeInterval)timeOut
             respondDataNumber:(NSInteger)respondNumber
                         start:(BOOL)start
            withCommandPostion:(HCKCommuCommandPostion)commandPostion
          communicationSuccess:(HCKDataCommunicationSuccessBlock)successBlock
      communicationFailedBlock:(HCKDataCommunicationFailedBlock)failedBlock{
    
    HCKCommandCommuObj *tempObj = [[HCKCommandCommuObj alloc] init];
    HCKCommunicationTask *task = [[HCKCommunicationTask alloc] initCommunicationTaskWithtarget:self
                                                                                      selector:@selector(processCommunicationObj:timeOut:)
                                                                                       Timeout:timeOut
                                                                                         queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
                                                                                    withObject:@(commandPostion)
                                                                                       repeats:NO];
    tempObj.receiveTimer = [self generateReceiveDataTimerWithCommandPostion:commandPostion];
    tempObj.task = task;
    tempObj.respondDataNumber = respondNumber;
    tempObj.communicationSuccessBlock = successBlock;
    tempObj.communicationFailedBlock = failedBlock;
    NSString *commandKey = bleStringFromInteger(commandPostion);
    [self.communicationDic setObject:tempObj
                              forKey:commandKey];
    if (!start) {
        return;
    }
    [task resume];
    //启动timer
    dispatch_resume(tempObj.receiveTimer);
}

/**
 数据通信的处理

 @param commandPostion 当前通信的信息
 @param timeOutType @(1)的时候是超时处理，@(0)的时候正常处理
 */
- (void)processCommunicationObj:(NSNumber *)commandPostion
                        timeOut:(NSNumber *)timeOutType{
    BOOL timeout = NO;
    if ([timeOutType integerValue] == 1) {
        timeout = YES;
    }
    HCKCommandCommuObj *tempModel = self.communicationDic[bleStringFromInteger([commandPostion integerValue])];
    if (!tempModel) {
        return ;
    }
    if (timeout || tempModel.timeOutStatus) {//超时处理
        if (tempModel.task) {
            [tempModel.task cancle];
        }
        if (tempModel.receiveTimer) {
            dispatch_cancel(tempModel.receiveTimer);
        }
        tempModel.timeOutStatus = YES;
        if (([commandPostion integerValue] == HCKCommuCommandPeripheralRequestStepData
            || [commandPostion integerValue] == HCKCommuCommandPeripheralRequestSleepIndex
            || [commandPostion integerValue] == HCKCommuCommandPeripheralRequestSleepRecord
            || [commandPostion integerValue] == HCKCommuCommandPeripheralRequestHeartRate)
            && [tempModel.dataList count] > 0) {
            //如果是计步、心率、睡眠数据的超时，则看接收到的数据条数，如果是没有接收到数据，则认为超时报错，如果接收到了数据，则认为是成功的
            //add程昂 2017-06-27
            HCKDataCommunicationSuccessBlock tempSuccessBlock = [tempModel.communicationSuccessBlock copy];
            NSMutableArray *tempDataArr = [tempModel.dataList mutableCopy];
            [self.communicationDic removeObjectForKey:bleStringFromInteger([commandPostion integerValue])];
            NSDictionary *resultDic = @{@"msg":@"success",
                                        @"code":@"1",
                                        @"result":(tempDataArr.count > 1) ? tempDataArr : tempDataArr[0],
                                        };
            dispatch_main_async_safe(^{
                tempSuccessBlock(resultDic);
            });
        }else{
            HCKDataCommunicationFailedBlock tempFailedBlock = [tempModel.communicationFailedBlock copy];
            [self.communicationDic removeObjectForKey:bleStringFromInteger([commandPostion integerValue])];
            communicationTimeout(tempFailedBlock);
        }
    }else if (!tempModel.timeOutStatus
              &&[tempModel.dataList count] == tempModel.respondDataNumber
              &&tempModel.communicationSuccessBlock){
        //正常处理
        if (tempModel.task) {
            [tempModel.task cancle];
        }
        if (tempModel.receiveTimer) {
            dispatch_cancel(tempModel.receiveTimer);
        }
        HCKDataCommunicationSuccessBlock tempSuccessBlock = [tempModel.communicationSuccessBlock copy];
        NSMutableArray *tempDataArr = [tempModel.dataList mutableCopy];
        [self.communicationDic removeObjectForKey:bleStringFromInteger([commandPostion integerValue])];
        NSDictionary *resultDic = @{@"msg":@"success",
                                    @"code":@"1",
                                    @"result":(tempDataArr.count > 1) ? tempDataArr : tempDataArr[0],
                                    };
        dispatch_main_async_safe(^{
            tempSuccessBlock(resultDic);
        });
    }else if (!tempModel.timeOutStatus){
        //正常接收到数据，进来要清接收数据超时定时器计数
        tempModel.timeoutCount = 0;
    }
}

/**
 生成接收数据超时定时器

 @return 定时器
 */
- (dispatch_source_t )generateReceiveDataTimerWithCommandPostion:(HCKCommuCommandPostion)postion{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,dispatch_get_global_queue(0, 0));
    //开始时间
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC);
    //间隔时间100ms
    uint64_t interval = 0.1 * NSEC_PER_SEC;
    dispatch_source_set_timer(timer, start, interval, 0);
    HCKBluetoothWS(weakSelf);
    //设置回调
    dispatch_source_set_event_handler(timer, ^{
        HCKCommandCommuObj *tempModel = weakSelf.communicationDic[bleStringFromInteger(postion)];
        if (!tempModel) {
            return ;
        }
        if (tempModel.timeOutStatus) {
            //如果是超时了，则直接返回
            dispatch_cancel(timer);
            return;
        }
        tempModel.timeoutCount ++;
        if (tempModel.timeoutCount * 0.1 >= receiveTimeoutTime) {
            //超过规定时间没有接收到新的数据，认为超时
            dispatch_cancel(timer);
            if (tempModel.task) {
                [tempModel.task cancle];
            }
            if ((postion == HCKCommuCommandPeripheralRequestStepData
                 || postion == HCKCommuCommandPeripheralRequestSleepIndex
                 || postion == HCKCommuCommandPeripheralRequestSleepRecord
                 || postion == HCKCommuCommandPeripheralRequestHeartRate)
                && [tempModel.dataList count] > 0) {
                //如果是计步、心率、睡眠数据的超时，则看接收到的数据条数，如果是没有接收到数据，则认为超时报错，如果接收到了数据，则认为是成功的
                //add程昂 2017-06-27
                HCKDataCommunicationSuccessBlock tempSuccessBlock = [tempModel.communicationSuccessBlock copy];
                NSMutableArray *tempDataArr = [tempModel.dataList mutableCopy];
                [weakSelf.communicationDic removeObjectForKey:bleStringFromInteger(postion)];
                NSDictionary *resultDic = @{@"msg":@"success",
                                            @"code":@"1",
                                            @"result":(tempDataArr.count > 1) ? tempDataArr : tempDataArr[0],
                                            };
                dispatch_main_async_safe(^{
                    if (!tempModel.timeOutStatus) {
                        tempSuccessBlock(resultDic);
                    }
                });
            }else{
                HCKDataCommunicationFailedBlock tempFailedBlock = [tempModel.communicationFailedBlock copy];
                [self.communicationDic removeObjectForKey:bleStringFromInteger(postion)];
                communicationTimeout(tempFailedBlock);
            }
        }
    });
    return timer;
}

- (NSArray *)getDetailSleepInfo:(NSInteger)SN{
    NSMutableArray * tempIndexArr = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < [self.sleepModel.sleepRecordArray count]; i ++) {
        NSDictionary *recordDic = self.sleepModel.sleepRecordArray[i];
        if ([recordDic[@"SN"] integerValue] == SN) {
            [tempIndexArr addObject:recordDic];
        }
    }
    
    NSArray *sortedArray = [tempIndexArr sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *dic1, NSDictionary *dic2){
        NSInteger index1 = [dic1[@"fragmentSN"] integerValue];
        NSInteger index2 = [dic2[@"fragmentSN"] integerValue];
        return [[NSNumber numberWithInteger:index1]
                compare:[NSNumber numberWithInteger:index2]];
    }];
    
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    
    for (NSInteger m = 0; m < [sortedArray count]; m ++) {
        NSDictionary *dic = [sortedArray objectAtIndex:m];
        [resultArr addObjectsFromArray:dic[@"detailSleepInfo"]];
    }
    
    return resultArr;
}

- (NSMutableArray *)createSleepResult{
    if (!HCKBluetoothValidArray(self.sleepModel.sleepRecordArray)
        || !HCKBluetoothValidArray(self.sleepModel.sleepIndexArray)) {
        return nil;
    }
    NSMutableArray *resultArray = [NSMutableArray array];
    
    for (id tempIndexDic in self.sleepModel.sleepIndexArray) {
        NSInteger SN = [tempIndexDic[@"SN"] integerValue];
        NSArray *sleepDetail = [self getDetailSleepInfo:SN];
        NSDictionary *sleepDic = @{
                                   @"SN":tempIndexDic[@"SN"],
                                   @"startYear":tempIndexDic[@"startYear"],
                                   @"startMonth":tempIndexDic[@"startMonth"],
                                   @"startDay":tempIndexDic[@"startDay"],
                                   @"startHour":tempIndexDic[@"startHour"],
                                   @"startMin":tempIndexDic[@"startMin"],
                                   @"endYear":tempIndexDic[@"endYear"],
                                   @"endMonth":tempIndexDic[@"endMonth"],
                                   @"endDay":tempIndexDic[@"endDay"],
                                   @"endHour":tempIndexDic[@"endHour"],
                                   @"endMin":tempIndexDic[@"endMin"],
                                   @"deepSleepTime":tempIndexDic[@"deepSleepTime"],
                                   @"lightSleepTime":tempIndexDic[@"lightSleepTime"],
                                   @"awake":tempIndexDic[@"awake"],
                                   @"detailedSleep":sleepDetail,
                                   };
        [resultArray addObject:sleepDic];
    }
    
    return resultArray;
}

- (NSArray *)getHeartRateDataArray:(id)returnData{
    if (!HCKBluetoothValidDict(returnData)) {
        return nil;
    }
    NSArray *dataArray = returnData[@"result"];
    if (!HCKBluetoothValidArray(dataArray)) {
        return nil;
    }
    return dataArray;
}

/**
 根据请求回来的memory数据，请求计步数据，返回的结果包含计步数据和手环电量
 
 @param data 请求回来的memory数据
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)processMemoryData:(id)data
             successBlock:(HCKDataCommunicationSuccessBlock)successBlock
              failedBlock:(HCKDataCommunicationFailedBlock)failedBlock{
    if (!HCKBluetoothValidDict(data)) {
        //请求数据出错
        requestPeripheralDataError(failedBlock);
        return;
    }
    NSString *commandStr = @"1601";
    NSData *commandData = [commandStr stringToData];
    [self initCommunicationTimer:requestPeripheralDataTime
               respondDataNumber:[data[@"result"][@"stepValue"] integerValue]
                           start:YES
              withCommandPostion:HCKCommuCommandPeripheralRequestStepData
            communicationSuccess:successBlock
        communicationFailedBlock:failedBlock];
    [self writeDataToPeripheral:commandData
             withCommandPostion:HCKCommuCommandPeripheralRequestStepData];
}

- (void)processSleepData:(id)data
            successBlock:(HCKDataCommunicationSuccessBlock)successBlock
             failedBlock:(HCKDataCommunicationFailedBlock)failedBlock{
    NSInteger sleepIndex = [data[@"result"][@"sleepIndexCount"] integerValue];
    NSInteger sleepRecord = [data[@"result"][@"sleepRecordCount"] integerValue];
    if (sleepIndex == 0
        || sleepRecord == 0) {
        if (successBlock) {
            NSDictionary *resultDic = @{@"msg":@"success",
                                        @"code":@"1",
                                        @"result":@[],
                                        };
            dispatch_main_async_safe(^{successBlock(resultDic);});
        }
        return ;
    }
    HCKBluetoothWS(weakSelf);
    [self requestPeripheralSleepIndexDataWithIndexCount:sleepIndex
                                            recordCount:sleepRecord
                                           successBlock:^(id returnData) {
                                               if (!HCKBluetoothValidDict(returnData)) {
                                                   requestPeripheralDataError(failedBlock);
                                                   [weakSelf.communicationDic removeObjectForKey:bleStringFromInteger(HCKCommuCommandPeripheralRequestSleepRecord)];
                                                   weakSelf.sleepModel.sleepIndexArray = nil;
                                                   weakSelf.sleepModel.sleepRecordArray = nil;
                                                   return ;
                                               }
                                               id tempSleepIndex = returnData[@"result"];
                                               if (HCKBluetoothValidDict(tempSleepIndex)) {
                                                   weakSelf.sleepModel.sleepIndexArray = [@[tempSleepIndex] mutableCopy];
                                               }else if (HCKBluetoothValidArray(tempSleepIndex)){
                                                   weakSelf.sleepModel.sleepIndexArray = tempSleepIndex;
                                               }
                                               //开始发送record命令
                                               NSString *commandStr = @"1603";
                                               NSData *commandData = [commandStr stringToData];
                                               HCKCommandCommuObj *tempModel = weakSelf.communicationDic[bleStringFromInteger(HCKCommuCommandPeripheralRequestSleepRecord)];
                                               if (!tempModel) {
                                                   return ;
                                               }
                                               if (tempModel.task) {
                                                   [tempModel.task resume];
                                               }
                                               if (tempModel.receiveTimer) {
                                                   dispatch_resume(tempModel.receiveTimer);
                                               }
                                               [weakSelf writeDataToPeripheral:commandData
                                                            withCommandPostion:HCKCommuCommandPeripheralRequestSleepRecord];
                                           }
                                            failedBlock:failedBlock];
    
    [self initCommunicationTimer:requestPeripheralDataTime
               respondDataNumber:sleepRecord
                           start:NO
              withCommandPostion:HCKCommuCommandPeripheralRequestSleepRecord
            communicationSuccess:successBlock
        communicationFailedBlock:failedBlock];
}


/**
 将传过来的yyyy-MM-dd-HH-mm格式的时间转换成十六进制的形式

 @param time yyyy-MM-dd-HH-mm格式的时间
 @return 按照年(16进制)、月(16进制)、日(16进制)、时(16进制)、分(16进制)顺序的字符串
 */
- (NSString *)getCurrentTimeString:(NSString *)time{
    NSArray *timeArray = [time componentsSeparatedByString:@"-"];
    if (!HCKBluetoothValidArray(timeArray)) {
        return nil;
    }
    unsigned long yearValue = [timeArray[0] integerValue] - 2000;
    NSString *hexTimeString = [NSString stringWithFormat:@"%1lx",yearValue];
    if (hexTimeString.length == 1) {
        hexTimeString = [@"0" stringByAppendingString:hexTimeString];
    }
    
    for (NSInteger i = 1; i < [timeArray count]; i ++) {
        unsigned long tempValue = [timeArray[i] integerValue];
        NSString *hexTempStr = [NSString stringWithFormat:@"%1lx",tempValue];
        if (hexTempStr.length == 1) {
            hexTempStr = [@"0" stringByAppendingString:hexTempStr];
        }
        hexTimeString = [hexTimeString stringByAppendingString:hexTempStr];
    }
    return hexTimeString;
}

/**
 处理最新睡眠数据
 
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)processLatestSleepWithTime:(NSString *)time
                      successBlock:(HCKDataCommunicationSuccessBlock)successBlock
                       failedBlock:(HCKDataCommunicationFailedBlock)failedBlock{
    NSString *dateInfo = [self getCurrentTimeString:time];
    if (!HCKBluetoothValidStr(dateInfo)) {
        requestPeripheralDataError(failedBlock);
        return;
    }
    
    NSString *hexTimeString = [dateInfo stringByAppendingString:@"94"];
    NSString *commandStr = [@"2c" stringByAppendingString:hexTimeString];
    NSData *commandData = [commandStr stringToData];
    HCKBluetoothWS(weakSelf);
    [self initCommunicationTimer:defaultCommandTime
               respondDataNumber:1
                           start:YES
              withCommandPostion:HCKCommuCommandPeripheralRequestLatestSleepRecordData
            communicationSuccess:^(id returnData) {
                if (!HCKBluetoothValidDict(returnData)) {
                    requestPeripheralDataError(failedBlock);
                }
                NSInteger sleepRecordNum = [returnData[@"result"][@"CNT"] integerValue];
                if (sleepRecordNum == 0) {
                    NSDictionary *resultDic = @{
                                                @"code":@"1",
                                                @"msg":@"success",
                                                @"result":@[]
                                                };
                    if (successBlock) {
                        dispatch_main_async_safe(^{successBlock(resultDic);});
                    }
                    return ;
                }
                [weakSelf initCommunicationTimer:requestPeripheralDataTime
                               respondDataNumber:sleepRecordNum
                                           start:YES
                              withCommandPostion:HCKCommuCommandPeripheralRequestSleepRecord
                            communicationSuccess:^(id returnData) {
                                if (!HCKBluetoothValidDict(returnData)) {
                                    requestPeripheralDataError(failedBlock);
                                    return ;
                                }
                                id tempResult = returnData[@"result"];
                                if ([tempResult isKindOfClass:[NSArray class]] && [tempResult count] == 0){
                                    //没有睡眠数据
                                    NSDictionary *resultDic = @{@"msg":@"success",
                                                                @"code":@"1",
                                                                @"result":@[],
                                                                };
                                    if (successBlock) {
                                        dispatch_main_async_safe(^{successBlock(resultDic);});
                                    }
                                    return;
                                    
                                }else if (HCKBluetoothValidArray(tempResult)){
                                    //多条睡眠数据
                                    weakSelf.sleepModel.sleepRecordArray = tempResult;
                                }else if (HCKBluetoothValidDict(tempResult)){
                                    //只有一条睡眠数据
                                    weakSelf.sleepModel.sleepRecordArray = [@[tempResult] mutableCopy];
                                }
                                
                                NSMutableArray *result = [weakSelf createSleepResult];
                                if (!HCKBluetoothValidArray(result)) {
                                    requestPeripheralDataError(failedBlock);
                                    return;
                                }
                                NSDictionary *resultDic = @{@"msg":@"success",
                                                            @"code":@"1",
                                                            @"result":result,
                                                            };
                                if (successBlock) {
                                    dispatch_main_async_safe(^{successBlock(resultDic);});
                                }
                            }
                        communicationFailedBlock:failedBlock];
            }
        communicationFailedBlock:failedBlock];
    [self writeDataToPeripheral:commandData
             withCommandPostion:HCKCommuCommandPeripheralRequestLatestSleepRecordData];
}

#pragma mark - Public Method

/**
 根据服务数组来扫描指定设备的特征值并连接设备
 
 @param services 服务数组
 @param successBlock 连接成功Block
 @param failedBlock 连接失败Block
 */
- (void)HCKPeripheralManagerDiscoverServices:(NSArray *)services
                                successBlock:(HCKCentralManagerConnectPeripheralSuccessBlock)successBlock
                                 failedBlock:(HCKCentralManagerConnectPeripheralFailedBlock)failedBlock{
    if (!self.connectedPeripheral
        || self.connectedPeripheral.state != CBPeripheralStateConnected) {
        if (failedBlock) {
            dispatch_main_async_safe(^{
                NSError *error = [[NSError alloc] initWithDomain:HCKCustomErrorDomain
                                                            code:customErrorCodeTimeOut
                                                        userInfo:@{@"errorInfo":@"Device connection error, fail to connect effective device"}];
                failedBlock(error);
            })
        }
        return;
    }
    self.connectSuccessBlock = successBlock;
    self.connectFailedBlock = failedBlock;
    self.connectedPeripheral.delegate = self;
    [self.connectedPeripheral discoverServices:@[[CBUUID UUIDWithString:@"FFC0"]]];
}

#pragma mark - 数据通信部分
#pragma mark - ====================================设置类指令========================================
/**
 手环震动指令
 
 @param successBlock 成功Block
 @param failedBlock 失败Block
 */
- (void)peripheralVibration:(HCKDataCommunicationSuccessBlock)successBlock
                failedBlock:(HCKDataCommunicationFailedBlock)failedBlock{
    if (!canSendCommand) {
        connectError(failedBlock);
        return;
    }
    NSString *commandStr = @"1702030a0a";
    NSData *commandData = [commandStr stringToData];
    [self initCommunicationTimer:defaultCommandTime
               respondDataNumber:1
                           start:YES
              withCommandPostion:HCKCommuCommandPeripheralVibration
            communicationSuccess:successBlock
        communicationFailedBlock:failedBlock];
    [self writeDataToPeripheral:commandData
             withCommandPostion:HCKCommuCommandPeripheralVibration];
}


/**
 手环屏幕单位进制选择

 @param unitType 单位类型，@"00"，@"01"英制
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)peripheralUnitSwitch:(NSString *)unitType
                successBlock:(HCKDataCommunicationSuccessBlock)successBlock
                failedBlock:(HCKDataCommunicationFailedBlock)failedBlock{
    if (!canSendCommand) {
        connectError(failedBlock);
        return;
    }
    if (!HCKBluetoothValidStr(unitType)) {
        paramsError(failedBlock);
        return;
    }
    NSString *commandStr = [@"23" stringByAppendingString:unitType];
    NSData *commandData = [commandStr stringToData];
    [self initCommunicationTimer:defaultCommandTime
               respondDataNumber:1
                           start:YES
              withCommandPostion:HCKCommuCommandPeripheralUnit
            communicationSuccess:successBlock
        communicationFailedBlock:failedBlock];
    [self writeDataToPeripheral:commandData
             withCommandPostion:HCKCommuCommandPeripheralUnit];
}

/**
 手环开启ancs指令

 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)peripheralOpenAncs:(HCKDataCommunicationSuccessBlock)successBlock
               failedBlock:(HCKDataCommunicationFailedBlock)failedBlock{
    if (!canSendCommand) {
        connectError(failedBlock);
        return;
    }
    NSString *commandStr = [@"16" stringByAppendingString:@"0f"];
    NSData *commandData = [commandStr stringToData];
    [self initCommunicationTimer:defaultCommandTime
               respondDataNumber:1
                           start:YES
              withCommandPostion:HCKCommuCommandPeripheralOpenANCS
            communicationSuccess:successBlock
        communicationFailedBlock:failedBlock];
    [self writeDataToPeripheral:commandData
             withCommandPostion:HCKCommuCommandPeripheralOpenANCS];
}

/**
 短信、电话、微信、qq、whatsapp、facebook、twitter、skype、snapchat，哪些功能开启ancs通知。使用本条指令的前提是已经使用了peripheralOpenAncs:failedBlock:命令将外设的ancs功能开启

 @param options 开启ancs通知的数组，顺序依次为短信、电话、微信、qq、whatsapp、facebook、twitter、skype、snapchat，@"00"关闭，@"01"开启。例如，全部关闭则是@[@"00",@"00",@"00",@"00",@"00",@"00",@"00",@"00",@"00"],全部开启@[@"01",@"01",@"01",@"01",@"01",@"01",@"01",@"01",@"01"],需要打开某个，则把相应位置写入@"01"，关闭@"00"即可
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)peripheralCorrespondANCSNotice:(NSArray *)options
                          successBlock:(HCKDataCommunicationSuccessBlock)successBlock
                           failedBlock:(HCKDataCommunicationFailedBlock)failedBlock{
    if (!canSendCommand) {
        connectError(failedBlock);
        return;
    }
    if (!([options isKindOfClass:[NSArray class]]
          && [options count] == 9)) {
        paramsError(failedBlock);
        return;
    }
    //判断数组里面是否都是字符串
    BOOL typeError = NO;
    for (id tempObj in options) {
        if (!HCKBluetoothValidStr(tempObj)) {
            typeError = YES;
            break;
        }
    }
    if (typeError) {
        paramsError(failedBlock);
        return;
    }
    HCKBluetoothWS(weakSelf);
    [self peripheralOpenAncs:^(id returnData) {
        if (!HCKBluetoothValidDict(returnData)) {
            return ;
        }
        NSArray *lowByteArray = [NSArray interceptionOfArray:options
                                                    subRange:NSMakeRange(0, 8)];
        unsigned long highByte = 0;
        if ([options[8] isEqualToString:@"01"]) {   //snapchat开启ancs提醒
            highByte |= 0x01;
        }
        NSString *lowByteString = [NSString getHexStringWithArray:lowByteArray];
        NSString *highByteString = [[NSString alloc] initWithFormat:@"%1lx",highByte];
        if (highByteString.length == 1) {
            highByteString = [@"0" stringByAppendingString:highByteString];
        }
        NSString *commandStr = [NSString stringWithFormat:@"%@%@%@%@%@%@",@"16",@"10",@"00",@"00",highByteString,lowByteString];
        NSData *commandData = [commandStr stringToData];
        [weakSelf initCommunicationTimer:defaultCommandTime
                   respondDataNumber:1
                               start:YES
                  withCommandPostion:HCKCommuCommandPeripheralANCSNotice
                communicationSuccess:successBlock
            communicationFailedBlock:failedBlock];
        
        [weakSelf writeDataToPeripheral:commandData
                 withCommandPostion:HCKCommuCommandPeripheralANCSNotice];
    }
                 failedBlock:failedBlock];
    
    
}

/**
 同步日期给手环，年:2000-2099

 @param dateInfo 日期信息，格式是:yyyy-MM-dd-HH-mm-ss
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)peripheralSynchronousDate:(NSString *)dateInfo
                     successBlock:(HCKDataCommunicationSuccessBlock)successBlock
                      failedBlock:(HCKDataCommunicationFailedBlock)failedBlock{
    if (!canSendCommand) {
        connectError(failedBlock);
        return;
    }
    BOOL paramErr = YES;
    NSArray *timeArray = nil;
    if (HCKBluetoothValidStr(dateInfo)) {
        timeArray = [dateInfo componentsSeparatedByString:@"-"];
        if ([timeArray isKindOfClass:[NSArray class]]
            && [timeArray count] == 6) {
            paramErr = NO;
        }
    }
    if (paramErr) {
        paramsError(failedBlock);
        return;
    }
    unsigned long yearValue = [timeArray[0] integerValue] - 2000;
    NSString *hexTimeString = [NSString stringWithFormat:@"%1lx",yearValue];
    if (hexTimeString.length == 1) {
        hexTimeString = [@"0" stringByAppendingString:hexTimeString];
    }
    
    for (NSInteger i = 1; i < [timeArray count]; i ++) {
        unsigned long tempValue = [timeArray[i] integerValue];
        NSString *hexTempStr = [NSString stringWithFormat:@"%1lx",tempValue];
        if (hexTempStr.length == 1) {
            hexTempStr = [@"0" stringByAppendingString:hexTempStr];
        }
        hexTimeString = [hexTimeString stringByAppendingString:hexTempStr];
    }
    
    NSString *commandStr = [@"11" stringByAppendingString:hexTimeString];
    NSData *commandData = [commandStr stringToData];
    [self initCommunicationTimer:defaultCommandTime
               respondDataNumber:1
                           start:YES
              withCommandPostion:HCKCommuCommandPeripheralDateInfo
            communicationSuccess:successBlock
        communicationFailedBlock:failedBlock];
    [self writeDataToPeripheral:commandData
             withCommandPostion:HCKCommuCommandPeripheralDateInfo];
}

/**
 同步用户身高体重等个人信息给手环

 @param weight 用户体重(30kg-150kg)
 @param height 用户身高(100cm-200cm)
 @param age 用户年龄(5-99)
 @param gender 用户性别(0:male,1:female)
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)peripheralSynchronousUserWeight:(NSInteger)weight
                                 height:(NSInteger)height
                                    age:(NSInteger)age
                                 gender:(NSInteger)gender
                           successBlock:(HCKDataCommunicationSuccessBlock)successBlock
                            failedBlock:(HCKDataCommunicationFailedBlock)failedBlock{
    if (!canSendCommand) {
        connectError(failedBlock);
        return;
    }
    if (weight < 30
        || weight > 150
        || height < 100
        || height > 200
        || age < 5
        || age > 99
        || gender < 0
        || gender > 1) {
        //参数错误
        paramsError(failedBlock);
        return;
    }
    
    NSString *hexAgeString = [NSString stringWithFormat:@"%1lx",(unsigned long)age];
    if (hexAgeString.length == 1) {
        hexAgeString = [@"0" stringByAppendingString:hexAgeString];
    }
    //步距的计算方法:步长=身高*0.45 ,并且向下取整，程昂修改于2017年6月10号
    NSInteger stepAway = floor(height * 0.45);
    NSString *commandStr = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                            @"12",
                            [NSString stringWithFormat:@"%1lx",(unsigned long)weight],
                            [NSString stringWithFormat:@"%1lx",(unsigned long)height],
                            hexAgeString,
                            [@"0" stringByAppendingString:bleStringFromInteger(gender)],
                            [NSString stringWithFormat:@"%1lx",(unsigned long)stepAway]];
    NSData *commandData = [commandStr stringToData];
    [self initCommunicationTimer:defaultCommandTime
               respondDataNumber:1
                           start:YES
              withCommandPostion:HCKCommuCommandPeripheralPersonalInformation
            communicationSuccess:successBlock
        communicationFailedBlock:failedBlock];
    [self writeDataToPeripheral:commandData
             withCommandPostion:HCKCommuCommandPeripheralPersonalInformation];
}

/**
 手环屏幕显示的时间进制，12h/24h

 @param timeFormat @"00":24h，@"01":12h
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)peripheralTimeFormat:(NSString *)timeFormat
                successBlock:(HCKDataCommunicationSuccessBlock)successBlock
                 failedBlock:(HCKDataCommunicationFailedBlock)failedBlock{
    if (!canSendCommand) {
        connectError(failedBlock);
        return;
    }
    if (!HCKBluetoothValidStr(timeFormat)) {
        paramsError(failedBlock);
        return;
    }
    
    NSString *commandStr = [@"24" stringByAppendingString:timeFormat];
    NSData *commandData = [commandStr stringToData];
    [self initCommunicationTimer:defaultCommandTime
               respondDataNumber:1
                           start:YES
              withCommandPostion:HCKCommuCommandPeripheralTimeFormat
            communicationSuccess:successBlock
        communicationFailedBlock:failedBlock];
    [self writeDataToPeripheral:commandData
             withCommandPostion:HCKCommuCommandPeripheralTimeFormat];
}

/**
 是否开启手环翻腕亮屏功能

 @param brightScreen YES:开启，NO:关闭
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)peripheralPalmingBrightScreen:(BOOL)brightScreen
                         successBlock:(HCKDataCommunicationSuccessBlock)successBlock
                          failedBlock:(HCKDataCommunicationFailedBlock)failedBlock{
    if (!canSendCommand) {
        connectError(failedBlock);
        return;
    }
    NSString *tempString = @"00";
    if (!brightScreen) {
        tempString = @"01";
    }
    NSString *commandStr = [@"25" stringByAppendingString:tempString];
    NSData *commandData = [commandStr stringToData];
    [self initCommunicationTimer:defaultCommandTime
               respondDataNumber:1
                           start:YES
              withCommandPostion:HCKCommuCommandPeripheralPalmingBrightScreen
            communicationSuccess:successBlock
        communicationFailedBlock:failedBlock];
    [self writeDataToPeripheral:commandData
             withCommandPostion:HCKCommuCommandPeripheralPalmingBrightScreen];
}

/**
 闹钟一共有两组，每组4个闹钟，手环最多支持8个闹钟

 @param index 闹钟数据所处的组别,0或者1，否则无效
 @param clockLists 闹钟对象数组，里面包含的必须是HCKAlarmClockModel这种对象，否则无效
 每次需要把需要设置的手环中有效的闹钟数据发送给"param clockLists "，不允许为空，否则出错,最多是4个闹钟数据，否则出错
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)peripheralAlarmClockIndex:(NSInteger)index
                       clockLists:(NSArray *)clockLists
                     successBlock:(HCKDataCommunicationSuccessBlock)successBlock
                      failedBlock:(HCKDataCommunicationFailedBlock)failedBlock{
    if (!HCKBluetoothValidArray(clockLists)
        ||[clockLists count] > 4
        ||index < 0
        ||index > 1){
        //参数错误
        paramsError(failedBlock);
        return;
    }
    NSMutableArray *tempArray = [NSMutableArray array];
    for (NSInteger i = 0; i < 16; i ++) {
        [tempArray addObject:@"00"];
    }
    for (NSInteger i = 0; i < [clockLists count]; i ++) {
        HCKAlarmClockModel *tempModel = clockLists[i];
        NSString *clockType = [NSString getAlarmClockTypeInfo:tempModel.clockType];
        //类型
        [tempArray replaceObjectAtIndex:i * 4
                             withObject:clockType];
        //开启时间
        NSString *clockSetting = [NSString getAlarmClockSettings:tempModel.clockSettings];
        [tempArray replaceObjectAtIndex:(i * 4 + 1)
                             withObject:clockSetting];
        //闹钟时间信息
        NSArray *tempTimeArray = [tempModel.clockTime componentsSeparatedByString:@":"];
        if ([tempTimeArray isKindOfClass:[NSArray class]]
            && [tempTimeArray count] == 2) {
            NSString *hexHour = [NSString stringWithFormat:@"%1lx",(unsigned long)[tempTimeArray[0] integerValue]];
            if (hexHour.length == 1) {
                hexHour = [@"0" stringByAppendingString:hexHour];
            }
            [tempArray replaceObjectAtIndex:(i * 4 + 2)
                                 withObject:hexHour];
            NSString *hexMin = [NSString stringWithFormat:@"%1lx",(unsigned long)[tempTimeArray[1] integerValue]];
            if (hexMin.length == 1) {
                hexMin = [@"0" stringByAppendingString:hexMin];
            }
            [tempArray replaceObjectAtIndex:(i * 4 + 3)
                                 withObject:hexMin];
        }
    }
    NSString *indexInfo = @"00";
    if (index == 1) {
        indexInfo = @"01";
    }
    NSString *commandStr = [@"26" stringByAppendingString:indexInfo];
    for (NSString *tempStr in tempArray) {
        commandStr = [commandStr stringByAppendingString:tempStr];
    }
    NSData *commandData = [commandStr stringToData];
    [self initCommunicationTimer:defaultCommandTime
               respondDataNumber:1
                           start:YES
              withCommandPostion:HCKCommuCommandPeripheralAlarmClockSetting
            communicationSuccess:successBlock
        communicationFailedBlock:failedBlock];
    [self writeDataToPeripheral:commandData
             withCommandPostion:HCKCommuCommandPeripheralAlarmClockSetting];
}

/**
 设置闹钟

 @param clockLists 闹钟对象数组，里面包含的必须是HCKAlarmClockModel这种对象，否则无效
 每次需要把需要设置的手环中有效的闹钟数据发送给"param clockLists "
 如果传入的该参数为nil或者个数为0，则会关闭所有的闹钟，
 闹钟个数最多8个闹钟，如果超过8个则调用失败，闹钟设置无效
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)peripheralSetAlarmClock:(NSArray *)clockLists
                   successBlock:(HCKDataCommunicationSuccessBlock)successBlock
                    failedBlock:(HCKDataCommunicationFailedBlock)failedBlock{
    if (!canSendCommand) {
        connectError(failedBlock);
        return;
    }
    if (!HCKBluetoothValidArray(clockLists)) {
        //关闭所有闹钟
        NSMutableArray *tempClockArray = [NSMutableArray array];
        for (NSInteger i = 0; i < 4; i ++) {
            HCKAlarmClockModel *model = [[HCKAlarmClockModel alloc] init];
            model.clockType = alarmClockNormal;
            model.clockSettings = @[@"00",@"00",@"00",@"00",@"00",@"00",@"00"];
            model.clockTime = @"00-00";
            [tempClockArray addObject:model];
        }
        HCKBluetoothWS(weakSelf);
        [self peripheralAlarmClockIndex:0
                             clockLists:tempClockArray
                           successBlock:^(id returnData) {
            [weakSelf peripheralAlarmClockIndex:1
                                     clockLists:tempClockArray
                                   successBlock:^(id returnData) {
                if (successBlock) {
                    dispatch_main_async_safe(^{
                        successBlock(returnData);
                    });
                }
            } failedBlock:^(NSError *error) {
                if (failedBlock) {
                    dispatch_main_async_safe(^{failedBlock(error);});
                }
            }];
        } failedBlock:^(NSError *error) {
            if (failedBlock) {
                dispatch_main_async_safe(^{failedBlock(error);});
            }
        }];
        return;
    }
    
    if ([clockLists count] > 8) {
        //参数错误
        paramsError(failedBlock);
        return;
    }
    BOOL paramError = NO;
    for (id tempModel in clockLists) {
        if (![tempModel isKindOfClass:[HCKAlarmClockModel class]]) {
            paramError = YES;
            break;
        }
        HCKAlarmClockModel *model = (HCKAlarmClockModel *)tempModel;
        NSArray *clockSetting = model.clockSettings;
        if (!HCKBluetoothValidArray(clockSetting)) {
            paramError = YES;
            break;
        }
        BOOL needBreak = NO;
        for (NSString *tempStr in clockSetting) {
            //如果传入的时间设置信息里面包含的不是@"00"或者@"01"，参数校验错误
            if (!([tempStr isEqualToString:@"00"]
                  || [tempStr isEqualToString:@"01"])) {
                needBreak = YES;
                break;
            }
        }
        if (needBreak) {
            paramError = YES;
            break;
        }
    }
    if (paramError) {
        //参数错误
        paramsError(failedBlock);
        return;
    }
    NSInteger addNumber = 8 - [clockLists count];
    NSMutableArray *clockListArray = [NSMutableArray arrayWithArray:clockLists];
    for (NSInteger i = 0; i < addNumber; i ++) {
        HCKAlarmClockModel *model = [[HCKAlarmClockModel alloc] init];
        model.clockType = alarmClockNormal;
        model.clockSettings = @[@"00",@"00",@"00",@"00",@"00",@"00",@"00"];
        model.clockTime = @"00:00";
        [clockListArray addObject:model];
    }
    
    HCKBluetoothWS(weakSelf);
    NSArray *clockLists1 = [NSArray interceptionOfArray:clockListArray
                                               subRange:NSMakeRange(0, 4)];
    NSArray *clockLists2 = [NSArray interceptionOfArray:clockListArray
                                               subRange:NSMakeRange(4, 4)];
    [self peripheralAlarmClockIndex:0
                         clockLists:clockLists1
                       successBlock:^(id returnData) {
        [weakSelf peripheralAlarmClockIndex:1
                                 clockLists:clockLists2
                               successBlock:^(id returnData) {
            if (successBlock) {
                dispatch_main_async_safe(^{successBlock(returnData);});
            }
        } failedBlock:^(NSError *error) {
            if (failedBlock) {
                dispatch_main_async_safe(^{failedBlock(error);});
            }
        }];
    } failedBlock:^(NSError *error) {
        if (failedBlock) {
            dispatch_main_async_safe(^{failedBlock(error);});
        }
    }];
}

/**
 手环是否记住上一次亮屏时的屏幕显示

 @param lastRemind YES:记住，NO:不记住
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)peripheralLastScreenDisplay:(BOOL)lastRemind
                       successBlock:(HCKDataCommunicationSuccessBlock)successBlock
                        failedBlock:(HCKDataCommunicationFailedBlock)failedBlock{
    if (!canSendCommand) {
        connectError(failedBlock);
        return;
    }
    NSString *tempString = @"00";
    if (lastRemind) {
        tempString = @"01";
    }
    NSString *commandStr = [@"27" stringByAppendingString:tempString];
    NSData *commandData = [commandStr stringToData];
    [self initCommunicationTimer:defaultCommandTime
               respondDataNumber:1
                           start:YES
              withCommandPostion:HCKCommuCommandPeripheralLastScreenDisplay
            communicationSuccess:successBlock
        communicationFailedBlock:failedBlock];
    [self writeDataToPeripheral:commandData
             withCommandPostion:HCKCommuCommandPeripheralLastScreenDisplay];
}

/**
 设置手环的久坐提醒，注意，当isOn=NO的时候，代表关闭来电提醒，这个时候startTime和endTime可以为空，当isOn=YES的时候，代表久坐提醒打开，这个时候，startTime和endTime不能为空

 @param isOn 久坐提醒状态，NO代表关闭，YES代表打开
 @param startTime 久坐提醒开始时间,时间格式HH:mm
 @param endTime 久坐提醒结束时间,时间格式HH:mm
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)peripheralSedentaryRemindWithStatus:(BOOL)isOn
                                  StartTime:(NSString *)startTime
                                       endTime:(NSString *)endTime
                                  successBlock:(HCKDataCommunicationSuccessBlock)successBlock
                                   failedBlock:(HCKDataCommunicationFailedBlock)failedBlock{
    if (!canSendCommand) {
        connectError(failedBlock);
        return;
    }
    if (isOn &&
        (!HCKBluetoothValidStr(startTime)
         || !HCKBluetoothValidStr(endTime))) {
        //参数错误
        paramsError(failedBlock);
        return;
    }
    NSArray *startArray = [startTime componentsSeparatedByString:@":"];
    NSArray *endArray = [endTime componentsSeparatedByString:@":"];
    if (!HCKBluetoothValidArray(startArray)
        || !HCKBluetoothValidArray(endArray)
        || startArray.count !=2
        || endArray.count != 2) {
        //参数错误
        paramsError(failedBlock);
        return;
    }
    NSMutableArray *tempCommandStrArray = [NSMutableArray array];
    for (NSInteger i = 0; i < 16; i ++) {
        [tempCommandStrArray addObject:@"00"];
    }
    if (isOn) {
        [tempCommandStrArray replaceObjectAtIndex:1
                                       withObject:@"ff"];
        //久坐提醒开始的时
        NSString *startHourHex = [NSString stringWithFormat:@"%1lx",(unsigned long)[startArray[0] integerValue]];
        if (startHourHex.length == 1) {
            startHourHex = [@"0" stringByAppendingString:startHourHex];
        }
        [tempCommandStrArray replaceObjectAtIndex:2
                                       withObject:startHourHex];
        //久坐提醒开始的分
        NSString *startMinHex = [NSString stringWithFormat:@"%1lx",(unsigned long)[startArray[1] integerValue]];
        if (startMinHex.length == 1) {
            startMinHex = [@"0" stringByAppendingString:startMinHex];
        }
        [tempCommandStrArray replaceObjectAtIndex:3
                                       withObject:startMinHex];
        //久坐提醒结束的时
        NSString *endHourHex = [NSString stringWithFormat:@"%1lx",(unsigned long)[endArray[0] integerValue]];
        if (endHourHex.length == 1) {
            endHourHex = [@"0" stringByAppendingString:endHourHex];
        }
        [tempCommandStrArray replaceObjectAtIndex:4
                                       withObject:endHourHex];
        //久坐提醒结束的分
        NSString *endMinHex = [NSString stringWithFormat:@"%1lx",(unsigned long)[endArray[1] integerValue]];
        if (endMinHex.length == 1) {
            endMinHex = [@"0" stringByAppendingString:endMinHex];
        }
        [tempCommandStrArray replaceObjectAtIndex:5
                                       withObject:endMinHex];
    }
    NSString *commandStr = @"2a";
    for (NSString *temp in tempCommandStrArray) {
        commandStr = [commandStr stringByAppendingString:temp];
    }
    NSData *commandData = [commandStr stringToData];
    [self initCommunicationTimer:defaultCommandTime
               respondDataNumber:1
                           start:YES
              withCommandPostion:HCKCommuCommandPeripheralSedentaryRemind
            communicationSuccess:successBlock
        communicationFailedBlock:failedBlock];
    [self writeDataToPeripheral:commandData
             withCommandPostion:HCKCommuCommandPeripheralSedentaryRemind];
}

/**
 设置手环心率采集的时间间隔

 @param interval 采集间隔，@"00":关闭心率采集,@"01":心率采集间隔为10分钟，@"02":心率采集间隔为20分钟，@"03":心率采集间隔为30分钟,其余无效
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)peripheralHeartRateAcquisitionInterval:(NSString *)interval
                                  successBlock:(HCKDataCommunicationSuccessBlock)successBlock
                                   failedBlock:(HCKDataCommunicationFailedBlock)failedBlock{
    if (!canSendCommand) {
        connectError(failedBlock);
        return;
    }
    if (!HCKBluetoothValidStr(interval)
        ||!([interval isEqualToString:@"00"]
            ||[interval isEqualToString:@"01"]
            ||[interval isEqualToString:@"02"]
            ||[interval isEqualToString:@"03"])) {
        //参数错误
            paramsError(failedBlock);
        return;
    }
    NSString *commandStr = [NSString stringWithFormat:@"%@%@%@%@",@"16",@"17",interval,@"00"];
    NSData *commandData = [commandStr stringToData];
    [self initCommunicationTimer:defaultCommandTime
               respondDataNumber:1
                           start:YES
              withCommandPostion:HCKCommuCommandPeripheralHeartRateAcquisitionInterval
            communicationSuccess:successBlock
        communicationFailedBlock:failedBlock];
    [self writeDataToPeripheral:commandData
             withCommandPostion:HCKCommuCommandPeripheralHeartRateAcquisitionInterval];
}

/**
 设置当前手环屏幕显示页面

 @param options 需要显示哪些页面，数组依次开关的页面为计步页面、心率页面、运动距离页面、卡路里页面、运动时间页面，全部显示为@[@"01",@"01",@"01",@"01",@"01"],全部不显示为@[@"00",@"00",@"00",@"00",@"00"]，要打开相应页面需要把相应位置写@"01"，关闭写@"00"
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)peripheralScreenDisplay:(NSArray *)options
                   successBlock:(HCKDataCommunicationSuccessBlock)successBlock
                    failedBlock:(HCKDataCommunicationFailedBlock)failedBlock{
    if (!canSendCommand) {
        connectError(failedBlock);
        return;
    }
    if (!HCKBluetoothValidArray(options)
        || [options count] != 5) {
        //参数错误
        paramsError(failedBlock);
        return;
    }
    BOOL paramError = NO;
    for (id tempStr in options) {
        if (!HCKBluetoothValidStr(tempStr)
            ||!([tempStr isEqualToString:@"00"]
                ||[tempStr isEqualToString:@"01"])) {
            paramError = YES;
            break;
        }
    }
    if (paramError) {
        //参数错误
        paramsError(failedBlock);
        return;
    }
    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:options];
    [tempArr insertObject:@"01" atIndex:0];
    [tempArr addObject:@"00"];
    [tempArr addObject:@"00"];
    NSString *hexCommand = [NSString getHexStringWithArray:tempArr];
    NSString *commandStr = [NSString stringWithFormat:@"%@%@%@%@",@"16",@"19",@"000000",hexCommand];
    NSData *commandData = [commandStr stringToData];
    [self initCommunicationTimer:defaultCommandTime
               respondDataNumber:1
                           start:YES
              withCommandPostion:HCKCommuCommandPeripheralScreenDisplay
            communicationSuccess:successBlock
        communicationFailedBlock:failedBlock];
    [self writeDataToPeripheral:commandData
             withCommandPostion:HCKCommuCommandPeripheralScreenDisplay];
}

/**
 关闭手环的ancs功能

 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)peripheralCloseANCSWithSuccessBlock:(HCKDataCommunicationSuccessBlock)successBlock
                                failedBlock:(HCKDataCommunicationFailedBlock)failedBlock{
    if (!canSendCommand) {
        connectError(failedBlock);
        return;
    }
    NSString *commandStr = @"1616";
    NSData *commandData = [commandStr stringToData];
    [self initCommunicationTimer:defaultCommandTime
               respondDataNumber:1
                           start:YES
              withCommandPostion:HCKCommuCommandPeripheralCloseANCS
            communicationSuccess:successBlock
        communicationFailedBlock:failedBlock];
    [self writeDataToPeripheral:commandData
             withCommandPostion:HCKCommuCommandPeripheralCloseANCS];
}

#pragma mark - ==============================请求手环数据部分指令======================

/**
 请求手环的memory数据，包含计步数据条数、当前设备电量

 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)requestPeripheralMemoryDataWithSuccessBlock:(HCKDataCommunicationSuccessBlock)successBlock
                                        failedBlock:(HCKDataCommunicationFailedBlock)failedBlock{
    if (!canSendCommand) {
        connectError(failedBlock);
        return;
    }
    NSString *commandStr = @"1600";
    NSData *commandData = [commandStr stringToData];
    [self initCommunicationTimer:defaultCommandTime
               respondDataNumber:1
                           start:YES
              withCommandPostion:HCKCommuCommandPeripheralRequestMemoryData
            communicationSuccess:successBlock
        communicationFailedBlock:failedBlock];
    [self writeDataToPeripheral:commandData
             withCommandPostion:HCKCommuCommandPeripheralRequestMemoryData];
}

/**
 请求手环电池电量

 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)requestPeripheralBatteryWithSuccessBlock:(HCKDataCommunicationSuccessBlock)successBlock
                                     failedBlock:(HCKDataCommunicationFailedBlock)failedBlock{
    if (!canSendCommand) {
        connectError(failedBlock);
        return;
    }
    [self requestPeripheralMemoryDataWithSuccessBlock:^(id returnData) {
        if (!HCKBluetoothValidDict(returnData)) {
            requestPeripheralDataError(failedBlock);
            return ;
        }
        NSString *battery = returnData[@"result"][@"battery"];
        if (!HCKBluetoothValidStr(battery)) {
            requestPeripheralDataError(failedBlock);
            return;
        }
        NSDictionary *tempDic = @{
                                    @"battery":battery
                                  };
        NSDictionary *resultDic = @{
                                    @"code":@"1",
                                    @"msg":@"success",
                                    @"result":tempDic
                                    };
        if (successBlock) {
            dispatch_main_async_safe(^{
                successBlock(resultDic);
            });
        }
    }
                                          failedBlock:failedBlock];
}

/**
 请求计步数据

 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)requestPeripheralStepDataWithSuccessBlock:(HCKDataCommunicationSuccessBlock)successBlock
                                      failedBlock:(HCKDataCommunicationFailedBlock)failedBlock{
    if (!canSendCommand) {
        connectError(failedBlock);
        return;
    }
    HCKBluetoothWS(weakSelf);
    [self requestPeripheralMemoryDataWithSuccessBlock:^(id returnData) {
        [weakSelf processMemoryData:returnData
                       successBlock:^(id returnData) {
            if (!HCKBluetoothValidDict(returnData)) {
                requestPeripheralDataError(failedBlock);
                return ;
            }
            NSArray *stepDataList = nil;
            id tempResult = returnData[@"result"];
            if (HCKBluetoothValidArray(tempResult)) {
                stepDataList = tempResult;
            }else if (HCKBluetoothValidDict(tempResult)){
                stepDataList = @[tempResult];
            }
            
            if (!HCKBluetoothValidArray(stepDataList)) {
                requestPeripheralDataError(failedBlock);
                return ;
            }
            NSDictionary *tempDic = @{
                                                @"stepList":stepDataList
                                                };;
            NSDictionary *resultDic = @{
                                        @"code":@"1",
                                        @"msg":@"success",
                                        @"result":tempDic
                                        };
            if (successBlock) {
                dispatch_main_async_safe(^{successBlock(resultDic);});
            }
            
        }
                        failedBlock:failedBlock];
    
    }
                                          failedBlock:failedBlock];
    
}

/**
 取消手环计步数据的返回处理，注意，调用了本方法，只是让SDK不再接受手环返回的计步数据，但是手环的通信不能被取消
 */
- (void)canclePeripheralStepRequest{
    //取消memeory的请求
    [self.communicationDic removeObjectForKey:bleStringFromInteger(HCKCommuCommandPeripheralRequestMemoryData)];
    //取消计步数据的请求
    [self.communicationDic removeObjectForKey:bleStringFromInteger(HCKCommuCommandPeripheralRequestStepData)];
}

/**
 请求手环睡眠总数(index和record)

 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)requestPeripheralTotalOfSleepWithSuccessBlock:(HCKDataCommunicationSuccessBlock)successBlock
                                          failedBlock:(HCKDataCommunicationFailedBlock)failedBlock{
    if (!canSendCommand) {
        connectError(failedBlock);
        return;
    }
    NSString *commandStr = @"1612";
    NSData *commandData = [commandStr stringToData];
    [self initCommunicationTimer:defaultCommandTime
               respondDataNumber:1
                           start:YES
              withCommandPostion:HCKCommuCommandPeripheralRequestTotalOfSleep
            communicationSuccess:successBlock
        communicationFailedBlock:failedBlock];
    [self writeDataToPeripheral:commandData
             withCommandPostion:HCKCommuCommandPeripheralRequestTotalOfSleep];
}

/**
 请求手环睡眠index数据

 @param indexCount 本次请求index数据的总条数
 @Param recordCount 本次请求record数据的总条数
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)requestPeripheralSleepIndexDataWithIndexCount:(NSInteger)indexCount
                                          recordCount:(NSInteger)recordCount
                                         successBlock:(HCKDataCommunicationSuccessBlock)successBlock
                                          failedBlock:(HCKDataCommunicationFailedBlock)failedBlock{
    if (!canSendCommand) {
        connectError(failedBlock);
        return;
    }
    NSString *commandStr = @"1602";
    NSData *commandData = [commandStr stringToData];
    [self initCommunicationTimer:requestPeripheralDataTime
               respondDataNumber:indexCount
                           start:YES
              withCommandPostion:HCKCommuCommandPeripheralRequestSleepIndex
            communicationSuccess:successBlock
        communicationFailedBlock:failedBlock];
    [self writeDataToPeripheral:commandData
             withCommandPostion:HCKCommuCommandPeripheralRequestSleepIndex];
}

/**
 请求手环睡眠reocrd数据的总条数

 @param count 本次请求record数据的总条数
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)requestPeripheralSleepRecordDataWithCount:(NSInteger)count
                                     successBlock:(HCKDataCommunicationSuccessBlock)successBlock
                                      failedBlock:(HCKDataCommunicationFailedBlock)failedBlock{
    if (!canSendCommand) {
        connectError(failedBlock);
        return;
    }
    [self initCommunicationTimer:requestPeripheralDataTime
               respondDataNumber:count
                           start:NO
              withCommandPostion:HCKCommuCommandPeripheralRequestSleepRecord
            communicationSuccess:successBlock
        communicationFailedBlock:failedBlock];
}

/**
 请求手环的睡眠数据

 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)requestPeripheralSleepDataWithSuccessBlock:(HCKDataCommunicationSuccessBlock)successBlock
                                       failedBlock:(HCKDataCommunicationFailedBlock)failedBlock{
    if (!canSendCommand) {
        connectError(failedBlock);
        return;
    }
    HCKBluetoothWS(weakSelf);
    [self requestPeripheralTotalOfSleepWithSuccessBlock:^(id returnData) {
        [weakSelf processSleepData:returnData
                      successBlock:^(id returnData) {
            if (!HCKBluetoothValidDict(returnData)) {
                requestPeripheralDataError(failedBlock);
                return ;
            }
            id tempResult = returnData[@"result"];
            if ([tempResult isKindOfClass:[NSArray class]] && [tempResult count] == 0){
                //没有睡眠数据
                NSDictionary *resultDic = @{@"msg":@"success",
                                            @"code":@"1",
                                            @"result":@[],
                                            };
                if (successBlock) {
                    dispatch_main_async_safe(^{successBlock(resultDic);});
                }
                return;
                
            }else if (HCKBluetoothValidArray(tempResult)){
                //多条睡眠数据
                weakSelf.sleepModel.sleepRecordArray = tempResult;
            }else if (HCKBluetoothValidDict(tempResult)){
                //只有一条睡眠数据
                weakSelf.sleepModel.sleepRecordArray = [@[tempResult] mutableCopy];
            }
            
            NSMutableArray *result = [weakSelf createSleepResult];
            if (!HCKBluetoothValidArray(result)) {
                requestPeripheralDataError(failedBlock);
                return;
            }
            NSDictionary *resultDic = @{@"msg":@"success",
                                        @"code":@"1",
                                        @"result":result,
                                        };
            if (successBlock) {
                dispatch_main_async_safe(^{successBlock(resultDic);});
            }
        }
                       failedBlock:failedBlock];
    }
                                            failedBlock:failedBlock];
}

/**
 取消手环睡眠数据的返回处理，注意，调用了本方法，只是让SDK不再接受手环返回的计步数据，但是手环的通信不能被取消
 */
- (void)canclePeripheralSleepRequest{
    //取消睡眠总数
    [self.communicationDic removeObjectForKey:bleStringFromInteger(HCKCommuCommandPeripheralRequestTotalOfSleep)];
    //取消睡眠index
    [self.communicationDic removeObjectForKey:bleStringFromInteger(HCKCommuCommandPeripheralRequestSleepIndex)];
    //取消睡眠record
    [self.communicationDic removeObjectForKey:bleStringFromInteger(HCKCommuCommandPeripheralRequestSleepRecord)];
}

/**
 请求手环心率数据
 
 @param number 本次心率总个数
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)requestPeripheralHeartRateDataWithDataNumber:(NSInteger)number
                                        SuccessBlock:(HCKDataCommunicationSuccessBlock)successBlock
                                         failedBlock:(HCKDataCommunicationFailedBlock)failedBlock{
    if (!canSendCommand) {
        connectError(failedBlock);
        return;
    }
    NSString *commandStr = @"1618";
    NSData *commandData = [commandStr stringToData];
    [self initCommunicationTimer:MAX((number * 0.3), 3)
               respondDataNumber:number
                           start:YES
              withCommandPostion:HCKCommuCommandPeripheralRequestHeartRate
            communicationSuccess:successBlock
        communicationFailedBlock:failedBlock];
    [self writeDataToPeripheral:commandData
             withCommandPostion:HCKCommuCommandPeripheralRequestHeartRate];
}

/**
 请求手环心率数据
 
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)requestPeripheralHeartRateDataWithSuccessBlock:(HCKDataCommunicationSuccessBlock)successBlock
                                           failedBlock:(HCKDataCommunicationFailedBlock)failedBlock{
    if (!canSendCommand) {
        connectError(failedBlock);
        return;
    }
    HCKBluetoothWS(weakSelf);
    [self requestPeripheralTotalOfSleepWithSuccessBlock:^(id returnData) {
        if (!HCKBluetoothValidDict(returnData)) {
            requestPeripheralDataError(failedBlock);
            return ;
        }
        NSInteger heartCount = [returnData[@"result"][@"heartRateCount"] integerValue];
        if (heartCount == 0) {
            NSDictionary *resultDic = @{
                                        @"code":@"1",
                                        @"msg":@"success",
                                        @"result":@[]
                                        };
            if (successBlock) {
                dispatch_main_async_safe(^{successBlock(resultDic);});
            }
            return ;
        }
        [weakSelf requestPeripheralHeartRateDataWithDataNumber:heartCount
                                                  SuccessBlock:^(id returnData) {
                                                      if (!HCKBluetoothValidDict(returnData)) {
                                                          requestPeripheralDataError(failedBlock);
                                                          return ;
                                                      }
                                                      NSArray *result = [weakSelf getHeartRateDataArray:returnData];
                                                      if (!HCKBluetoothValidArray(result)) {
                                                          requestPeripheralDataError(failedBlock);
                                                          return;
                                                      }
                                                      NSDictionary *resultDic = @{
                                                                                    @"code":@"1",
                                                                                    @"msg":@"success",
                                                                                    @"result":result
                                                                                  };
                                                      if (successBlock) {
                                                          dispatch_main_async_safe(^{successBlock(resultDic);});
                                                      }
                                                      
                                                  }
                                                   failedBlock:failedBlock];
    } failedBlock:failedBlock];
}

/**
 取消手环心率数据的返回处理，注意，调用了本方法，只是让SDK不再接受手环返回的计步数据，但是手环的通信不能被取消
 */
- (void)canclePeripheralHeartRateRequest{
    [self.communicationDic removeObjectForKey:bleStringFromInteger(HCKCommuCommandPeripheralRequestTotalOfSleep)];
    [self.communicationDic removeObjectForKey:bleStringFromInteger(HCKCommuCommandPeripheralRequestHeartRate)];
}

/**
 请求手环固件版本号

 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)requestPeripheralFirwareVersionWithSuccessBlock:(HCKDataCommunicationSuccessBlock)successBlock
                                            failedBlock:(HCKDataCommunicationFailedBlock)failedBlock{
    if (!canSendCommand) {
        connectError(failedBlock);
        return;
    }
    NSString *commandStr = @"1606";
    NSData *commandData = [commandStr stringToData];
    [self initCommunicationTimer:defaultCommandTime
               respondDataNumber:1
                           start:YES
              withCommandPostion:HCKCommuCommandPeripheralRequestFirmwareVersion
            communicationSuccess:successBlock
        communicationFailedBlock:failedBlock];
    [self writeDataToPeripheral:commandData
             withCommandPostion:HCKCommuCommandPeripheralRequestFirmwareVersion];
}

/**
 手环是否有心率功能

 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)requestPeripheralWhetherHasHeartRateDataWithSuccessBlock:(HCKDataCommunicationSuccessBlock)successBlock
                                                     failedBlock:(HCKDataCommunicationFailedBlock)failedBlock{
    if (!canSendCommand) {
        connectError(failedBlock);
        return;
    }
    [self requestPeripheralInternalVersionWithSuccessBlock:^(id returnData) {
        if (!HCKBluetoothValidDict(returnData)) {
            requestPeripheralDataError(failedBlock);
            return ;
        }
        NSString *dataString = returnData[@"result"][@"internalVersion"];
        if (!HCKBluetoothStrValid(dataString)
            || dataString.length != 6) {
            requestPeripheralDataError(failedBlock);
            return;
        }
        NSInteger v1 = strtoul([[dataString substringWithRange:NSMakeRange(2, 2)] UTF8String],0,16);
        BOOL supportHeartRate = NO;
        if (v1 & 0x01) {//支持心率
            supportHeartRate = YES;
        }
        NSDictionary *resultDic = @{
                                    @"code":@"1",
                                    @"msg":@"success",
                                    @"result":@{
                                                @"supportHeartRate":@(supportHeartRate),
                                            }
                                    };
        if (successBlock) {
            dispatch_main_async_safe(^{successBlock(resultDic);});
        }
        
    } failedBlock:failedBlock];
}
/*
请求手环内部版本号

@param successBlock 成功回调
@param failedBlock 失败回调
*/
- (void)requestPeripheralInternalVersionWithSuccessBlock:(HCKDataCommunicationSuccessBlock)successBlock
                                             failedBlock:(HCKDataCommunicationFailedBlock)failedBlock{
    if (!canSendCommand) {
        connectError(failedBlock);
        return;
    }
    NSString *commandStr = @"1609";
    NSData *commandData = [commandStr stringToData];
    [self initCommunicationTimer:defaultCommandTime
               respondDataNumber:1
                           start:YES
              withCommandPostion:HCKCommuCommandPeripheralRequestInternalVersionNumber
            communicationSuccess:successBlock
        communicationFailedBlock:failedBlock];
    [self writeDataToPeripheral:commandData
             withCommandPostion:HCKCommuCommandPeripheralRequestInternalVersionNumber];
}

/**
 请求手环当天的数据
 
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)requestPeripheralDataOfTodayWithSuccessBlock:(HCKDataCommunicationSuccessBlock)successBlock
                                         failedBlock:(HCKDataCommunicationFailedBlock)failedBlock{
    if (!canSendCommand) {
        connectError(failedBlock);
        return;
    }
    NSString *commandStr = @"1613";
    NSData *commandData = [commandStr stringToData];
    HCKBluetoothWS(weakSelf);
    [self initCommunicationTimer:requestPeripheralDataTime
               respondDataNumber:1
                           start:YES
              withCommandPostion:HCKCommuCommandPeripheralRequestDataOfToday
            communicationSuccess:^(id returnData) {
                if (!HCKBluetoothValidDict(returnData)) {
                    requestPeripheralDataError(failedBlock);
                    return ;
                }
                //睡眠index总数
                NSInteger sleepIndexNum = [returnData[@"result"][@"sleepIndexCount"] integerValue];
                //睡眠record总数
                NSInteger sleepRecordNum = [returnData[@"result"][@"sleepRecrodCount"] integerValue];
                //心率个数
                NSInteger heartNum = [returnData[@"result"][@"heartRateCount"] integerValue];
                __block BOOL stepSuccess = NO;
                __block BOOL sleepIndexSuccess = NO;
                __block BOOL sleepRecordSuccess = NO;
                __block BOOL heartRateSuccess = NO;
                __block NSArray *stepArray = nil;
                __block NSArray *sleepIndexArray = nil;
                __block NSArray *sleepRecordArray = nil;
                __block NSArray *heartArray = nil;
                //创建计步任务
                [weakSelf initCommunicationTimer:requestPeripheralDataTime
                               respondDataNumber:1
                                           start:YES
                              withCommandPostion:HCKCommuCommandPeripheralRequestStepData
                            communicationSuccess:^(id returnData) {
                                if (HCKBluetoothValidDict(returnData)) {
                                    stepArray = @[returnData[@"result"]];
                                    //请求计步成功
                                    stepSuccess = YES;
                                }
                            }
                        communicationFailedBlock:failedBlock];
                
                //创建睡眠index任务
                [weakSelf initCommunicationTimer:requestPeripheralDataTime
                               respondDataNumber:(sleepIndexNum > 0 ? sleepIndexNum : 1)
                                           start:YES
                              withCommandPostion:HCKCommuCommandPeripheralRequestSleepIndex
                            communicationSuccess:^(id returnData) {
                                if (HCKBluetoothValidDict(returnData)) {
                                    sleepIndexArray = @[returnData[@"result"]];
                                    //请求睡眠index成功
                                    sleepIndexSuccess = YES;
                                }
                                
                            }
                        communicationFailedBlock:failedBlock];
                //创建睡眠record任务
                [weakSelf initCommunicationTimer:requestPeripheralDataTime
                               respondDataNumber:(sleepRecordNum > 0 ? sleepRecordNum : 1)
                                           start:YES
                              withCommandPostion:HCKCommuCommandPeripheralRequestSleepRecord
                            communicationSuccess:^(id returnData) {
                                if (HCKBluetoothValidDict(returnData)) {
                                    if ([returnData[@"result"] isKindOfClass:[NSDictionary class]]) {
                                        sleepRecordArray = @[returnData[@"result"]];
                                    }else if ([returnData[@"result"] isKindOfClass:[NSArray class]]){
                                        sleepRecordArray = returnData[@"result"];
                                    }
                                    
                                    //请求睡眠record成功
                                    sleepRecordSuccess = YES;
                                    if (heartNum == 0) {
                                        //没有心率数据的情况下
                                        if (!(stepSuccess
                                              && sleepIndexSuccess
                                              && sleepRecordSuccess
                                              && stepArray
                                              && sleepIndexArray
                                              && sleepRecordArray)) {
                                            //同步失败
                                            requestPeripheralDataError(failedBlock);
                                            return ;
                                        }
                                        //同步成功
                                        NSDictionary *resultDic = @{
                                                                    @"code":@"1",
                                                                    @"msg":@"success",
                                                                    @"result":@{
                                                                            @"stepList":stepArray,
                                                                            @"sleepIndexList":sleepIndexArray,
                                                                            @"sleepRecordList":sleepRecordArray,
                                                                            @"heartRateList":@[],
                                                                            }
                                                                    };
                                        if (successBlock) {
                                            dispatch_main_async_safe(^{successBlock(resultDic);});
                                        }
                                    }
                                }
                            }
                        communicationFailedBlock:failedBlock];
                //如果heartNum = 0表示没有心率数据(手环又可能不支持心率功能)
                if (heartNum == 0) {
                    return;
                }
                //创建心率任务
                [weakSelf initCommunicationTimer:heartNum * 0.3
                               respondDataNumber:heartNum
                                           start:YES
                              withCommandPostion:HCKCommuCommandPeripheralRequestHeartRate
                            communicationSuccess:^(id returnData) {
                                if (!HCKBluetoothValidDict(returnData)) {
                                    requestPeripheralDataError(failedBlock);
                                    return ;
                                }
                                //请求心率成功
                                heartRateSuccess = YES;
                                heartArray = [self getHeartRateDataArray:returnData];
                                if (!(stepSuccess
                                      && sleepIndexSuccess
                                      && sleepRecordSuccess
                                      && heartRateSuccess
                                      && stepArray
                                      && sleepIndexArray
                                      && sleepRecordArray
                                      && heartArray)) {
                                    //同步失败
                                    requestPeripheralDataError(failedBlock);
                                    return ;
                                }
                                //同步成功
                                NSDictionary *resultDic = @{
                                                            @"code":@"1",
                                                            @"msg":@"success",
                                                            @"result":@{
                                                                        @"stepList":stepArray,
                                                                        @"sleepIndexList":sleepIndexArray,
                                                                        @"sleepRecordList":sleepRecordArray,
                                                                        @"heartRateList":heartArray,
                                                                    }
                                                            };
                                if (successBlock) {
                                    dispatch_main_async_safe(^{successBlock(resultDic);});
                                }
                            }
                        communicationFailedBlock:failedBlock];
            }
        communicationFailedBlock:failedBlock];
    [self writeDataToPeripheral:commandData
             withCommandPostion:HCKCommuCommandPeripheralRequestDataOfToday];
}

/**
 时间戳形式请求计步数据
 
 @param time yyyy-MM-dd-HH-mm格式的时间字符串
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)requestPeripheralLatestStepDataWithTime:(NSString *)time
                                   successBlock:(HCKDataCommunicationSuccessBlock)successBlock
                                    failedBlock:(HCKDataCommunicationFailedBlock)failedBlock{
    NSString *dateInfo = [self getCurrentTimeString:time];
    if (!HCKBluetoothValidStr(dateInfo)) {
        requestPeripheralDataError(failedBlock);
        return;
    }
    
    NSString *hexTimeString = [dateInfo stringByAppendingString:@"92"];
    NSString *commandStr = [@"2c" stringByAppendingString:hexTimeString];
    NSData *commandData = [commandStr stringToData];
    HCKBluetoothWS(weakSelf);
    [self initCommunicationTimer:requestPeripheralDataTime
               respondDataNumber:1
                           start:YES
              withCommandPostion:HCKCommuCommandPeripheralRequestLatestStepData
            communicationSuccess:^(id returnData) {
                if (!HCKBluetoothValidDict(returnData)) {
                    requestPeripheralDataError(failedBlock);
                    return ;
                }
                NSInteger stepNum = [returnData[@"result"][@"CNT"] integerValue];
                if (stepNum == 0) {
                    NSDictionary *resultDic = @{
                                                @"code":@"1",
                                                @"msg":@"success",
                                                @"result":@[]
                                                };
                    if (successBlock) {
                        dispatch_main_async_safe(^{successBlock(resultDic);});
                    }
                    return ;
                }
                [weakSelf initCommunicationTimer:requestPeripheralDataTime
                               respondDataNumber:stepNum
                                           start:YES
                              withCommandPostion:HCKCommuCommandPeripheralRequestStepData
                            communicationSuccess:successBlock
                        communicationFailedBlock:failedBlock];
    }
        communicationFailedBlock:failedBlock];
    [self writeDataToPeripheral:commandData
             withCommandPostion:HCKCommuCommandPeripheralRequestLatestStepData];
}

/**
 时间戳形式请求睡眠数据
 
 @param time yyyy-MM-dd-HH-mm格式的时间字符串
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)requestPeripheralLatestSleepDataWithTime:(NSString *)time
                                    successBlock:(HCKDataCommunicationSuccessBlock)successBlock
                                     failedBlock:(HCKDataCommunicationFailedBlock)failedBlock{
    NSString *dateInfo = [self getCurrentTimeString:time];
    if (!HCKBluetoothValidStr(dateInfo)) {
        requestPeripheralDataError(failedBlock);
        return;
    }
    
    NSString *hexTimeString = [dateInfo stringByAppendingString:@"93"];
    NSString *commandStr = [@"2c" stringByAppendingString:hexTimeString];
    NSData *commandData = [commandStr stringToData];
    HCKBluetoothWS(weakSelf);
    
    [self initCommunicationTimer:requestPeripheralDataTime
               respondDataNumber:1
                           start:YES
              withCommandPostion:HCKCommuCommandPeripheralRequestLatestSleepIndexData
            communicationSuccess:^(id returnData) {
                if (!HCKBluetoothValidDict(returnData)) {
                    requestPeripheralDataError(failedBlock);
                    return ;
                }
                NSInteger sleepIndexNum = [returnData[@"result"][@"CNT"] integerValue];
                if (sleepIndexNum == 0) {
                    NSDictionary *resultDic = @{
                                                @"code":@"1",
                                                @"msg":@"success",
                                                @"result":@[]
                                                };
                    if (successBlock) {
                        dispatch_main_async_safe(^{successBlock(resultDic);});
                    }
                    return ;
                }

                [weakSelf initCommunicationTimer:requestPeripheralDataTime
                               respondDataNumber:sleepIndexNum
                                           start:YES
                              withCommandPostion:HCKCommuCommandPeripheralRequestSleepIndex
                            communicationSuccess:^(id returnData) {
                                id tempSleepIndex = returnData[@"result"];
                                if (HCKBluetoothValidDict(tempSleepIndex)) {
                                    weakSelf.sleepModel.sleepIndexArray = [@[tempSleepIndex] mutableCopy];
                                }else if (HCKBluetoothValidArray(tempSleepIndex)){
                                    weakSelf.sleepModel.sleepIndexArray = tempSleepIndex;
                                }
                                [weakSelf processLatestSleepWithTime:time
                                                        successBlock:successBlock
                                                         failedBlock:failedBlock];
                }
                        communicationFailedBlock:failedBlock];
    }
        communicationFailedBlock:failedBlock];
    [self writeDataToPeripheral:commandData
             withCommandPostion:HCKCommuCommandPeripheralRequestLatestSleepIndexData];
}

/**
 时间戳形式请求心率数据
 
 @param time yyyy-MM-dd-HH-mm格式的时间字符串
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)requestPeripheralLatestHeartRateDataWithTime:(NSString *)time
                                        successBlock:(HCKDataCommunicationSuccessBlock)successBlock
                                         failedBlock:(HCKDataCommunicationFailedBlock)failedBlock{
    NSString *dateInfo = [self getCurrentTimeString:time];
    if (!HCKBluetoothValidStr(dateInfo)) {
        requestPeripheralDataError(failedBlock);
        return;
    }
    
    NSString *hexTimeString = [dateInfo stringByAppendingString:@"a8"];
    NSString *commandStr = [@"2c" stringByAppendingString:hexTimeString];
    NSData *commandData = [commandStr stringToData];
    HCKBluetoothWS(weakSelf);
    [self initCommunicationTimer:requestPeripheralDataTime
               respondDataNumber:1
                           start:YES
              withCommandPostion:HCKCommuCommandPeripheralRequestLatestHeartRate
            communicationSuccess:^(id returnData) {
                if (!HCKBluetoothValidDict(returnData)) {
                    requestPeripheralDataError(failedBlock);
                    return ;
                }
                NSInteger heartRateNum = [returnData[@"result"][@"CNT"] integerValue];
                if (heartRateNum == 0) {
                    NSDictionary *resultDic = @{
                                                @"code":@"1",
                                                @"msg":@"success",
                                                @"result":@[]
                                                };
                    if (successBlock) {
                        dispatch_main_async_safe(^{successBlock(resultDic);});
                    }
                    return ;
                }
                [weakSelf initCommunicationTimer:MAX(heartRateNum * 0.3, 3)
                               respondDataNumber:heartRateNum * 3
                                           start:YES
                              withCommandPostion:HCKCommuCommandPeripheralRequestHeartRate
                            communicationSuccess:^(id returnData) {
                                if (!HCKBluetoothValidDict(returnData)) {
                                    requestPeripheralDataError(failedBlock);
                                    return ;
                                }
                                NSArray *result = [weakSelf getHeartRateDataArray:returnData];
                                if (!HCKBluetoothValidArray(result)) {
                                    requestPeripheralDataError(failedBlock);
                                    return;
                                }
                                NSDictionary *resultDic = @{
                                                            @"code":@"1",
                                                            @"msg":@"success",
                                                            @"result":result
                                                            };
                                if (successBlock) {
                                    dispatch_main_async_safe(^{successBlock(resultDic);});
                                }
                            } communicationFailedBlock:failedBlock];
    }
        communicationFailedBlock:failedBlock];
    [self writeDataToPeripheral:commandData
             withCommandPostion:HCKCommuCommandPeripheralRequestLatestHeartRate];
}


#pragma mark - setter & getter
- (void)setConnectedPeripheral:(CBPeripheral *)connectedPeripheral{
    objc_setAssociatedObject(self,
                             &HCKConnectedPeripheralKey,
                             connectedPeripheral,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CBPeripheral *)connectedPeripheral{
    return objc_getAssociatedObject(self,
                                    &HCKConnectedPeripheralKey);
}

- (NSMutableDictionary *)communicationDic{
    if (!_communicationDic) {
        _communicationDic = [NSMutableDictionary dictionary];
    }
    return _communicationDic;
}

- (sleepDataModel *)sleepModel{
    if (!_sleepModel) {
        _sleepModel = [[sleepDataModel alloc] init];
    }
    return _sleepModel;
}

@end
