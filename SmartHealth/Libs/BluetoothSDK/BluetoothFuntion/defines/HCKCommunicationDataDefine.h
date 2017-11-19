//
//  HCKCommunicationDataDefine.h
//  BluetoothDemo
//
//  Created by aa on 17/4/21.
//  Copyright © 2017年 HCK. All rights reserved.
//

#ifndef HCKCommunicationDataDefine_h
#define HCKCommunicationDataDefine_h

#import <Foundation/Foundation.h>

//手环固件版本号
static NSString *const peripheralFirmwareVersionRequestFrameHeader = @"90";
//memory数据回复帧
static NSString *const peripheralMemoryRequestResponseFrameHeader = @"91";
//计步数据回复帧
static NSString *const peripheralStepRequestResponseFrameHeader = @"92";
//睡眠index数据回复帧
static NSString *const peripheralSleepIndexRequestResponseFrameHeader = @"93";
//睡眠reocrd数据回复帧
static NSString *const peripheralSleepRecordRequestResponseFrameHeader = @"94";
//通用回复帧
static NSString *const generalResponseFrameHeader = @"96";
//睡眠总数、心率采集间隔、手环屏幕显示
static NSString *const peripheralTotalOfSleepRelatedFrameHeader = @"a5";
//心率数据
static NSString *const peripheralHeartRateRequestResponseFrameHeader = @"a8";
//最新数据个数计步、睡眠index、睡眠record、心率
static NSString *const peripheralLatestDataRequestResponseFrameHeader = @"aa";

#endif /* HCKCommunicationDataDefine_h */
