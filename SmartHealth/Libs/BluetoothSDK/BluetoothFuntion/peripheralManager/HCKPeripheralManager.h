//
//  HCKPeripheralManager.h
//  BluetoothDemo
//
//  Created by aa on 17/4/19.
//  Copyright © 2017年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "HCKBluetoothGlobal.h"

@interface HCKPeripheralManager : NSObject

/**
 当前连接的设备
 */
@property (nonatomic, strong)CBPeripheral *connectedPeripheral;

#pragma mark - Public Method
+ (HCKPeripheralManager *)sharedPeripheralManager;

/**
 根据服务数组来扫描指定设备的特征值并连接设备

 @param services 服务数组
 @param successBlock 连接成功Block
 @param failedBlock 连接失败Block
 */
- (void)HCKPeripheralManagerDiscoverServices:(NSArray *)services
                                successBlock:(HCKCentralManagerConnectPeripheralSuccessBlock)successBlock
                                 failedBlock:(HCKCentralManagerConnectPeripheralFailedBlock)failedBlock;

#pragma mark - 数据通信部分
/**
 手环震动指令
 
 @param successBlock 成功Block
 @param failedBlock 失败Block
 */
- (void)peripheralVibration:(HCKDataCommunicationSuccessBlock)successBlock
                failedBlock:(HCKDataCommunicationFailedBlock)failedBlock;

/**
 手环屏幕单位进制选择
 
 @param unitType 单位类型，@"00"公制，@"01"英制
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)peripheralUnitSwitch:(NSString *)unitType
                successBlock:(HCKDataCommunicationSuccessBlock)successBlock
                 failedBlock:(HCKDataCommunicationFailedBlock)failedBlock;

/**
 手环开启ancs指令
 
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)peripheralOpenAncs:(HCKDataCommunicationSuccessBlock)successBlock
               failedBlock:(HCKDataCommunicationFailedBlock)failedBlock;

/**
 短信、电话、微信、qq、whatsapp、facebook、twitter、skype、snapchat，哪些功能开启ancs通知。使用本条指令的前提是已经使用了peripheralOpenAncs:failedBlock:命令将外设的ancs功能开启
 
 @param options 开启ancs通知的数组，顺序依次为短信、电话、微信、qq、whatsapp、facebook、twitter、skype、snapchat，@"00"关闭，@"01"开启。例如，全部关闭则是@[@"00",@"00",@"00",@"00",@"00",@"00",@"00",@"00",@"00"],全部开启@[@"01",@"01",@"01",@"01",@"01",@"01",@"01",@"01",@"01"],需要打开某个，则把相应位置写入01，关闭00即可
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)peripheralCorrespondANCSNotice:(NSArray *)options
                          successBlock:(HCKDataCommunicationSuccessBlock)successBlock
                           failedBlock:(HCKDataCommunicationFailedBlock)failedBlock;

/**
 同步日期给手环，年:2000-2099
 
 @param dateInfo 日期信息，格式是:yyyy-MM-dd-HH-mm-ss
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)peripheralSynchronousDate:(NSString *)dateInfo
                     successBlock:(HCKDataCommunicationSuccessBlock)successBlock
                      failedBlock:(HCKDataCommunicationFailedBlock)failedBlock;

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
                            failedBlock:(HCKDataCommunicationFailedBlock)failedBlock;

/**
 手环屏幕显示的时间进制，12h/24h
 
 @param timeFormat @"00":24h，@"01":12h
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)peripheralTimeFormat:(NSString *)timeFormat
                successBlock:(HCKDataCommunicationSuccessBlock)successBlock
                 failedBlock:(HCKDataCommunicationFailedBlock)failedBlock;

/**
 是否开启手环翻腕亮屏功能
 
 @param brightScreen YES:开启，NO:关闭
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)peripheralPalmingBrightScreen:(BOOL)brightScreen
                         successBlock:(HCKDataCommunicationSuccessBlock)successBlock
                          failedBlock:(HCKDataCommunicationFailedBlock)failedBlock;

/**
 手环是否记住上一次亮屏时的屏幕显示
 
 @param lastRemind YES:记住，NO:不记住
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)peripheralLastScreenDisplay:(BOOL)lastRemind
                       successBlock:(HCKDataCommunicationSuccessBlock)successBlock
                        failedBlock:(HCKDataCommunicationFailedBlock)failedBlock;

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
                    failedBlock:(HCKDataCommunicationFailedBlock)failedBlock;

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
                                failedBlock:(HCKDataCommunicationFailedBlock)failedBlock;

/**
 设置手环心率采集的时间间隔
 
 @param interval 采集间隔，@"00":关闭心率采集,@"01":心率采集间隔为10分钟，@"02":心率采集间隔为20分钟，@"03":心率采集间隔为30分钟,其余无效
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)peripheralHeartRateAcquisitionInterval:(NSString *)interval
                                  successBlock:(HCKDataCommunicationSuccessBlock)successBlock
                                   failedBlock:(HCKDataCommunicationFailedBlock)failedBlock;

/**
 设置当前手环屏幕显示页面
 
 @param options 需要显示哪些页面，数组依次开关的页面为计步页面、心率页面、运动距离页面、卡路里页面、运动时间页面，全部显示为@[@"01",@"01",@"01",@"01",@"01"],全部不显示为@[@"00",@"00",@"00",@"00",@"00"]，要打开相应页面需要把相应位置写@"01"，关闭写@"00"
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)peripheralScreenDisplay:(NSArray *)options
                   successBlock:(HCKDataCommunicationSuccessBlock)successBlock
                    failedBlock:(HCKDataCommunicationFailedBlock)failedBlock;

///**
// 关闭手环的ancs功能
// 
// @param successBlock 成功回调
// @param failedBlock 失败回调
// */
//- (void)peripheralCloseANCSWithSuccessBlock:(HCKDataCommunicationSuccessBlock)successBlock
//                                failedBlock:(HCKDataCommunicationFailedBlock)failedBlock;

#pragma mark - =============请求手环数据API=============
/**
 请求手环的memory数据，包含计步数据条数、当前设备电量
 
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)requestPeripheralMemoryDataWithSuccessBlock:(HCKDataCommunicationSuccessBlock)successBlock
                                        failedBlock:(HCKDataCommunicationFailedBlock)failedBlock;

/**
 请求手环电池电量
 
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)requestPeripheralBatteryWithSuccessBlock:(HCKDataCommunicationSuccessBlock)successBlock
                                     failedBlock:(HCKDataCommunicationFailedBlock)failedBlock;

/**
 请求计步数据
 
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)requestPeripheralStepDataWithSuccessBlock:(HCKDataCommunicationSuccessBlock)successBlock
                                      failedBlock:(HCKDataCommunicationFailedBlock)failedBlock;

/**
 取消手环计步数据的返回处理，注意，调用了本方法，只是让SDK不再接受手环返回的计步数据，但是手环的通信不能被取消
 */
- (void)canclePeripheralStepRequest;

/**
 请求手环的睡眠数据
 
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)requestPeripheralSleepDataWithSuccessBlock:(HCKDataCommunicationSuccessBlock)successBlock
                                       failedBlock:(HCKDataCommunicationFailedBlock)failedBlock;

/**
 取消手环睡眠数据的返回处理，注意，调用了本方法，只是让SDK不再接受手环返回的计步数据，但是手环的通信不能被取消
 */
- (void)canclePeripheralSleepRequest;

/**
 请求手环心率数据

 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)requestPeripheralHeartRateDataWithSuccessBlock:(HCKDataCommunicationSuccessBlock)successBlock
                                           failedBlock:(HCKDataCommunicationFailedBlock)failedBlock;

/**
 取消手环心率数据的返回处理，注意，调用了本方法，只是让SDK不再接受手环返回的计步数据，但是手环的通信不能被取消
 */
- (void)canclePeripheralHeartRateRequest;

/**
 请求手环固件版本号
 
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)requestPeripheralFirwareVersionWithSuccessBlock:(HCKDataCommunicationSuccessBlock)successBlock
                                            failedBlock:(HCKDataCommunicationFailedBlock)failedBlock;

/**
 手环是否有心率功能
 
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)requestPeripheralWhetherHasHeartRateDataWithSuccessBlock:(HCKDataCommunicationSuccessBlock)successBlock
                                                     failedBlock:(HCKDataCommunicationFailedBlock)failedBlock;

/**
 请求手环内部版本号

 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)requestPeripheralInternalVersionWithSuccessBlock:(HCKDataCommunicationSuccessBlock)successBlock
                                             failedBlock:(HCKDataCommunicationFailedBlock)failedBlock;

/**
 请求手环当天的数据

 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)requestPeripheralDataOfTodayWithSuccessBlock:(HCKDataCommunicationSuccessBlock)successBlock
                                         failedBlock:(HCKDataCommunicationFailedBlock)failedBlock;


/**
 时间戳形式请求计步数据

 @param time yyyy-MM-dd-HH-mm格式的时间字符串
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)requestPeripheralLatestStepDataWithTime:(NSString *)time
                                   successBlock:(HCKDataCommunicationSuccessBlock)successBlock
                                    failedBlock:(HCKDataCommunicationFailedBlock)failedBlock;


/**
 时间戳形式请求睡眠数据

 @param time yyyy-MM-dd-HH-mm格式的时间字符串
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)requestPeripheralLatestSleepDataWithTime:(NSString *)time
                                    successBlock:(HCKDataCommunicationSuccessBlock)successBlock
                                     failedBlock:(HCKDataCommunicationFailedBlock)failedBlock;


/**
 时间戳形式请求心率数据

 @param time yyyy-MM-dd-HH-mm格式的时间字符串
 @param successBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)requestPeripheralLatestHeartRateDataWithTime:(NSString *)time
                                        successBlock:(HCKDataCommunicationSuccessBlock)successBlock
                                         failedBlock:(HCKDataCommunicationFailedBlock)failedBlock;

@end
