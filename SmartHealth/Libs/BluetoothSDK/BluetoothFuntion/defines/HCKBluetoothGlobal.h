//
//  HCKBluetoothGlobal.h
//  BluetoothDemo
//
//  Created by aa on 17/4/18.
//  Copyright © 2017年 HCK. All rights reserved.
//

#ifndef HCKBluetoothGlobal_h
#define HCKBluetoothGlobal_h

#import "CBPeripheral+HCKAdditionalInfo.h"
#import "NSArray+HCKBluetoothAdd.h"
#import "NSString+HCKBluetoothAdd.h"
#import "HCKCommunicationLogFileManager.h"

#pragma mark - *************************  block弱引用强引用  *************************
//===================弱引用对象=====================================//
#define HCKBluetoothWS(weakSelf)          __weak __typeof(&*self)weakSelf = self;

#pragma mark - 字符串、字典、数组等类的验证宏定义
//*************************************字符串、字典、数组等类的验证宏定义******************************************************

#define HCKBluetoothStrDate(s)          (s==nil ? [NSDate date] : s)
#define HCKBluetoothStrValid(f)         (f!=nil && [f isKindOfClass:[NSString class]] && ![f isEqualToString:@""])

#define HCKBluetoothValidStr(f)         HCKBluetoothStrValid(f)
#define HCKBluetoothValidDict(f)        (f!=nil && [f isKindOfClass:[NSDictionary class]] && [f count]>0)
#define HCKBluetoothValidArray(f)       (f!=nil && [f isKindOfClass:[NSArray class]] && [f count]>0)
#define HCKBluetoothValidNum(f)         (f!=nil && [f isKindOfClass:[NSNumber class]])
#define HCKBluetoothValidClass(f,cls)   (f!=nil && [f isKindOfClass:[cls class]])
#define HCKBluetoothValidData(f)        (f!=nil && [f isKindOfClass:[NSData class]])

#define HCKBluetoothDataStr(str)        [str dataUsingEncoding:NSUTF8StringEncoding]
//*************************************字符串、字典、数组等类的验证宏定义******************************************************

#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

//将NSInteger转换成相应的NSString
#define bleStringFromInteger(value) [NSString stringWithFormat:@"%ld",(long)(value)]
#pragma mark - =====================枚举定义部分==========================
/*
 自定义的错误码
 */
typedef NS_ENUM(NSInteger, HCKCustomErrorCode){
    customErrorCodeRequestPeripheralDataError = -10000,                     //请求手环数据出错
    customErrorCodeTimeOut = -10001,                                        //超时
    customErrorCodeBlueUnuseable = -10002,                                  //当前手机蓝牙不可用
    customErrorCodeUUIDError = -10003,                                      //要连接的UUID错误，
    customErrorCodeMacError = -10004,                                       //指定要连接的外设mac地址有误
    customErrorCodeScanPeripheralListEmpty = -10005,                        //没有扫描到任何的外设
    customErrorCodeConnectedFailed = -10006,                                //连接外设失败
    customErrorCodeConnectSpecifiedInfoErroe = -10007,                      //连接指定设备的依据不合法
    customErrorCodePeripheralUnconnected = -10008,                          //当前外部连接的设备处于断开状态
    customErrorCodeCommunicationTimeOut = -10009,                           //数据通信超时
    customErrorCodePeripheralConnectedAlready = -10010,                     //已经存在连接的设备或者正在连接外设
    customErrorCodeCentralIsScanning = -10010,                              //当前中心正在扫描
    customErrorCodeOptionsError = -10011,                                   //输入的参数有误
};

/**
 当前manager的功能，扫描设备、通过UUID连接设备、通过MAC地址连接设备、通过MAC地址低四位连接设备
 */
typedef NS_ENUM(NSInteger, HCKCurrentManagerFunction) {
    HCKCurrentManagerFunctionScan,                                             //当前manager处于扫描状态
    HCKCurrentManagerFunctionConnectPeriphearlWithUUID,                        //当前manager处于通过UUID连接状态
    HCKCurrentManagerFunctionConnectPeriphearlWithMAC,                         //当前manager处于通过MAC地址连接状态
    HCKCurrentManagerFunctionConnectPeriphearlWithMACLowFour,                  //当前manager处于通过MAC地址低四位连接状态
    HCKCurrentManagerFunctionConnectPeripheralWithPeripheral,                  //当前manager处于通过指定具体设备连接状态
};

/**
 监控当前中心设备和外设之间的连接状态

 - HCKPeripheralConnectStatusUnknow: 未知状态，外设不可用
 */
typedef NS_ENUM(NSInteger, HCKPeripheralConnectStatus) {
    HCKPeripheralConnectStatusUnknow,                                           //未知状态
    HCKPeripheralConnectStatusConnecting,                                       //正在连接
    HCKPeripheralConnectStatusConnected,                                        //连接成功
    HCKPeripheralConnectStatusConnectedFailed,                                  //连接失败
    HCKPeripheralConnectStatusDisconnect,                                       //连接断开
    
};

typedef NS_ENUM(NSInteger, HCKCentralManagerState) {
    HCKCentralManagerStateUnknow,                           //未知状态
    HCKCentralManagerStateEnable,                           //可用状态
    HCKCentralManagerStateUnable,                           //不可用
};

typedef NS_ENUM(NSInteger, HCKCommuCommandPostion) {
#pragma mark - 设置类指令
    HCKCommuCommandPeripheralOpenANCS,              //开启ancs
    HCKCommuCommandPeripheralANCSNotice,            //写ancs通知
    HCKCommuCommandPeripheralDateInfo,              //同步当前日期
    HCKCommuCommandPeripheralPersonalInformation,   //同步个人信息
    HCKCommuCommandPeripheralVibration,             //手环震动
    HCKCommuCommandPeripheralUnit,                  //同步进制单位信息,国际/英国
    HCKCommuCommandPeripheralTimeFormat,            //时间进制，12/24
    HCKCommuCommandPeripheralPalmingBrightScreen,   //翻腕亮屏
    HCKCommuCommandPeripheralAlarmClockSetting,     //闹钟设置
    HCKCommuCommandPeripheralLastScreenDisplay,     //上一次屏幕显示
    HCKCommuCommandPeripheralSedentaryRemind,       //久坐提醒
    HCKCommuCommandPeripheralHeartRateAcquisitionInterval,  //心率采集间隔
    HCKCommuCommandPeripheralScreenDisplay,         //手环屏幕显示
    HCKCommuCommandPeripheralCloseANCS,             //手环关闭ancs功能
    HCKCommuCommandPeripheralHeartAck,              //心率数据最开头的回复帧
    
#pragma mark - 读取手环数据指令
    HCKCommuCommandPeripheralRequestMemoryData,     //请求手环memory数据
    HCKCommuCommandPeripheralRequestStepData,       //请求手环计步数据
    HCKCommuCommandPeripheralRequestTotalOfSleep,   //请求手环睡眠总数
    HCKCommuCommandPeripheralRequestSleepIndex,     //请求手环睡眠index
    HCKCommuCommandPeripheralRequestSleepRecord,    //请求手环睡眠record
    HCKCommuCommandPeripheralRequestHeartRate,      //请求手环心率数据
    HCKCommuCommandPeripheralRequestFirmwareVersion,//请求手环固件版本号
    HCKCommuCommandPeripheralRequestInternalVersionNumber,  //请求手环内部版本号，用来判断手环是否有心率功能
    HCKCommuCommandPeripheralRequestDataOfToday,    //请求当天数据，计步、睡眠、心率
    HCKCommuCommandPeripheralRequestLatestStepData, //请求手环最新计步数据
    HCKCommuCommandPeripheralRequestLatestSleepIndexData,    //请求手环最新睡眠index数据
    HCKCommuCommandPeripheralRequestLatestSleepRecordData,   //请求手环最新睡眠record数据
    HCKCommuCommandPeripheralRequestLatestHeartRate,    //请求手环最新心率数据
};

static NSString * const HCKCustomErrorDomain = @"com.moko.fitpoloBluetoothSDK";

#define needCommunicationLog HCKLogFileManager.openLog

#define HCKLogFileManager [HCKCommunicationLogFileManager sharedLogFileManager]
#define needCommunicationLog HCKLogFileManager.openLog

#define HCKBluetoothCentralManager [HCKCentralManager sharedCentralManager]
#define HCKBluetoothPeripheralManager [HCKPeripheralManager sharedPeripheralManager]
#define HCKBluetoothStatusManager [HCKConnectionStatusMonitoringManager sharedStatusMonitoringManger]

#pragma mark - =============================Block定义部分==================================
/**
 扫描外设的Block
 
 @param error 扫描出错
 @param peripheralList 扫描成功时返回的设备列表
 */
typedef void(^HCKScanPeripheralResultBlock)(NSError *error, NSArray *peripheralList);

/**
 中心设备连接外设失败的Block
 
 @param error 错误信息
 */
typedef void(^HCKCentralManagerConnectPeripheralFailedBlock)(NSError *error);

/**
 连接设备成功Block
 
 @param periphearl 已连接的外设
 @param UUID 已连接外设的UUID
 @param MAC 已连接外设的MAC地址
 */
typedef void(^HCKCentralManagerConnectPeripheralSuccessBlock)(CBPeripheral *periphearl, NSString *UUID, NSString *MAC);

/**
 数据通信成功

 @param returnData 返回的Json数据
 */
typedef void(^HCKDataCommunicationSuccessBlock)(id returnData);

/**
 数据通信失败

 @param error 失败原因
 */
typedef void(^HCKDataCommunicationFailedBlock)(NSError *error);

/**
 监测当前中心和外设连接状态

 @param status 连接状态
 */
typedef void(^HCKConnectStatusChangedBlock)(HCKPeripheralConnectStatus status);

/**
 监测当前中心的蓝牙状态

 @param status 蓝牙状态
 */
typedef void(^HCKCentralManagerStatusChangedBlock)(HCKCentralManagerState status);

#pragma mark -=====================HCKCentralManager与外设连接状态的通知部分=====================
//中心开始扫描设备
static NSString *const HCKCentralManagerStartScanNotification = @"HCKCentralManagerStartScanNotification";
//中心开始连接外设
static NSString *const HCKCentralManagerStartConnectPeripheralNotification = @"HCKCentralManagerStartConnectPeripheralNotification";
//连接设备成功
static NSString *const HCKCentralManagerConnectSuccessNotification = @"HCKCentralManagerConnectSuccessNotification";
//连接设备失败
static NSString *const HCKCentralManagerConnectFailedNotification = @"HCKCentralManagerConnectFailedNotification";
//与外设断开连接
static NSString *const HCKCentralManagerDisconnectPeripheralNotification = @"HCKCentralManagerDisconnectPeripheralNotification";

static NSString *const HCKCentralManagerBluetoothStateChangedNotification = @"HCKCentralManagerBluetoothStateChangedNotification";

#endif /* HCKBluetoothGlobal_h */
