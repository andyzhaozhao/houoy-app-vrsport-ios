//
//  HCKCommuDataConversionTool.m
//  BluetoothDemo
//
//  Created by aa on 17/4/21.
//  Copyright © 2017年 HCK. All rights reserved.
//

#import "HCKCommuDataConversionTool.h"
#import "HCKCommunicationDataDefine.h"

@implementation HCKCommuDataConversionTool

/**
 将手环回复的数据转换成HCKCommuDataConvModel
 
 @param dataString 需要转换的手环数据
 @return HCKCommuDataConvModel
 */
+(HCKCommuDataConvModel *)communicationDataConvToModel:(NSString *)dataString{
    if (!HCKBluetoothValidStr(dataString)
        || dataString.length <= 3) {
        
        if (needCommunicationLog) {
            [HCKLogFileManager writeCommandToLocalFile:@[@"手环返回数据出错"]
                                     withSourceInfo:HCKLocalDataSourceDevice];
        }
        return nil;
    }
    //回复的数据帧头
    NSString *frameHeaderInfo = [dataString substringWithRange:NSMakeRange(0, 2)];
    if (!HCKBluetoothValidStr(frameHeaderInfo)) {
        if (needCommunicationLog) {
            [HCKLogFileManager writeCommandToLocalFile:@[@"手环返回数据出错"]
                                     withSourceInfo:HCKLocalDataSourceDevice];
        }
        return nil;
    }
    NSString *functionInfo = [dataString substringWithRange:NSMakeRange(2, dataString.length - 2)];
    if ([frameHeaderInfo isEqualToString:peripheralFirmwareVersionRequestFrameHeader]) {
        //手环固件版本号
        return [self getPeripheralFirmwareVersionJsonData:functionInfo];
    }else if ([frameHeaderInfo isEqualToString:generalResponseFrameHeader]){
        //通用回复帧头@"96"
        return [self getGeneralResponseJsonData:functionInfo];
    }else if ([frameHeaderInfo isEqualToString:peripheralMemoryRequestResponseFrameHeader]){
        //手环memory数据@"91"
        return [self getMemoryDataJsonData:functionInfo];
    }else if ([frameHeaderInfo isEqualToString:peripheralStepRequestResponseFrameHeader]){
        //计步92
        return [self getStepDataJsonData:functionInfo];
    }else if ([frameHeaderInfo isEqualToString:peripheralSleepIndexRequestResponseFrameHeader]){
        //睡眠index数据回复帧93
        return [self getSleepIndexJsonData:functionInfo];
    }else if ([frameHeaderInfo isEqualToString:peripheralSleepRecordRequestResponseFrameHeader]){
        //睡眠reocrd数据回复帧94
        return [self getSleepRecordJsonData:functionInfo];
    }else if ([frameHeaderInfo isEqualToString:peripheralTotalOfSleepRelatedFrameHeader]){
        //睡眠总数、心率采集间隔、手环屏幕显示a5、当天睡眠心率个数
        return [self getTotalOfSleepRelatedJsonData:functionInfo];
    }else if ([frameHeaderInfo isEqualToString:peripheralHeartRateRequestResponseFrameHeader]){
        //心率数据a8
        return [self getPeripheralHeartRateData:functionInfo];
    }else if ([frameHeaderInfo isEqualToString:peripheralLatestDataRequestResponseFrameHeader]){
        //最新计步、睡眠index、睡眠record、心率数据
        return [self getPeripheralLatestData:functionInfo];
    }

    return nil;
}

#pragma mark - private Method

/**
 将睡眠详情转换成详细的数组数据

 @param binaryStr 睡眠详情
 @return 睡眠数据数组
 */
+ (NSMutableArray *)getSleepDetailInfo:(NSString *)binaryStr{
    if (!HCKBluetoothValidStr(binaryStr)) {
        return nil;
    }
    NSMutableArray * tempArr = [[NSMutableArray alloc] init];
    NSInteger index = 0;
    for (NSInteger i = 0; i < ([binaryStr length] / 2); i ++) {
        NSString * tempStr = [binaryStr substringWithRange:NSMakeRange(index, 2)];
        if ([tempStr isEqualToString:@"11"]) {
            tempStr = @"00";
        }
        [tempArr addObject:tempStr];
        index += 2;
    }
    NSMutableArray * resultArr = (NSMutableArray *)[[tempArr reverseObjectEnumerator] allObjects];
    return resultArr;
}

#pragma mark - parseData
/**
 对于手环回复的96开头的数据帧，解析成相应的json
 @return 解析后的json
 */
+ (HCKCommuDataConvModel *)getGeneralResponseJsonData:(NSString *)dataString{
    if (!HCKBluetoothValidStr(dataString)
        || !(dataString.length == 2
             || dataString.length == 8)) {
        if (needCommunicationLog) {
            [HCKLogFileManager writeCommandToLocalFile:@[@"手环返回数据出错"]
                                     withSourceInfo:HCKLocalDataSourceDevice];
        }
        return nil;
    }
    if (needCommunicationLog) {
        NSString *tempWriteString = [NSString stringWithFormat:@"手环返回数据:96%@",dataString];
        [HCKLogFileManager writeCommandToLocalFile:@[tempWriteString]
                                 withSourceInfo:HCKLocalDataSourceDevice];
    }
    HCKCommuDataConvModel *tempModel = [[HCKCommuDataConvModel alloc] init];
    tempModel.commuData = @{};
    HCKCommuCommandPostion postion;
    NSString *function = [dataString substringWithRange:NSMakeRange(0, 2)];
    if ([function isEqualToString:@"09"]) {
        //请求手环内部版本号，用来判断是否有心率功能
        postion = HCKCommuCommandPeripheralRequestInternalVersionNumber;
        tempModel.commuData = @{
                                    @"internalVersion":[dataString substringWithRange:NSMakeRange(2, 6)],
                                };
//        if (dataString.length == 8) {
//            NSInteger v1 = strtoul([[dataString substringWithRange:NSMakeRange(4, 2)] UTF8String],0,16);
//            BOOL supportHeartRate = NO;
//            if (v1 & 0x01) {//支持心率
//                supportHeartRate = YES;
//            }
//            tempModel.commuData = @{
//                                        @"supportHeartRate":@(supportHeartRate)
//                                    };
//        }
        
    }else if ([function isEqualToString:@"0f"]){
        //开启ancs
        postion = HCKCommuCommandPeripheralOpenANCS;
    }else if ([function isEqualToString:@"10"]){
        //写ANCS通知
        postion = HCKCommuCommandPeripheralANCSNotice;
    }else if ([function isEqualToString:@"11"]){
        //日期
        postion = HCKCommuCommandPeripheralDateInfo;
    }else if ([function isEqualToString:@"12"]){
        //个人信息
        postion = HCKCommuCommandPeripheralPersonalInformation;
    }else if ([function isEqualToString:@"17"]){
        //震动
        postion = HCKCommuCommandPeripheralVibration;
    }
    else if ([function isEqualToString:@"23"]){
        //单位选择
        postion = HCKCommuCommandPeripheralUnit;
    }else if ([function isEqualToString:@"24"]){
        //时间进制
        postion = HCKCommuCommandPeripheralTimeFormat;
    }else if ([function isEqualToString:@"25"]){
        //翻腕亮屏
        postion = HCKCommuCommandPeripheralPalmingBrightScreen;
    }else if ([function isEqualToString:@"26"]){
        //闹钟
        postion = HCKCommuCommandPeripheralAlarmClockSetting;
    }else if ([function isEqualToString:@"27"]){
        //显示上一次屏幕
        postion = HCKCommuCommandPeripheralLastScreenDisplay;
    }else if ([function isEqualToString:@"2a"]){
        //久坐提醒
        postion = HCKCommuCommandPeripheralSedentaryRemind;
    }
    tempModel.commandPostion = postion;
    return tempModel;
}

/**
 手环memory数据转换成json
 @param dataString 手环传过来的memory数据
 @return 返回的json
 */
+ (HCKCommuDataConvModel *)getMemoryDataJsonData:(NSString *)dataString{
    if (!HCKBluetoothValidStr(dataString) || dataString.length != 6) {
        if (needCommunicationLog) {
            [HCKLogFileManager writeCommandToLocalFile:@[@"手环返回memory数据出错"]
                                     withSourceInfo:HCKLocalDataSourceDevice];
        }
        return nil;
    }
    if (needCommunicationLog) {
        NSString *tempWriteString = [NSString stringWithFormat:@"手环返回memory数据:91%@",
                                     dataString];
        [HCKLogFileManager writeCommandToLocalFile:@[tempWriteString]
                                 withSourceInfo:HCKLocalDataSourceDevice];
    }
    HCKCommuDataConvModel *dataModel = [[HCKCommuDataConvModel alloc] init];
    dataModel.commandPostion = HCKCommuCommandPeripheralRequestMemoryData;
    NSInteger stepNum = strtoul([[dataString substringWithRange:NSMakeRange(0, 2)] UTF8String],0,16);
    NSInteger batteryNum = strtoul([[dataString substringWithRange:NSMakeRange(4, 2)] UTF8String],0,16);
    NSDictionary *jsonDic = @{
                                @"stepValue":bleStringFromInteger(stepNum),
                                @"battery":bleStringFromInteger(batteryNum)
                              };
    if (needCommunicationLog) {
        NSString *tempWriteString1 = [NSString stringWithFormat:@"解析后的memory数据:计步数据个数:%ld",
                                     (long)stepNum];
        NSString *tempWriteString2 = [NSString stringWithFormat:@"解析后的memory数据:电池电量:%ld",
                                      (long)batteryNum];
        [HCKLogFileManager writeCommandToLocalFile:@[tempWriteString1,tempWriteString2]
                                 withSourceInfo:HCKLocalDataSourceDevice];
    }
    dataModel.commuData = jsonDic;
    return dataModel;
}

/**
 手环计步数据转成json

 @param dataString 手环的计步数据
 @return 返回的json
 */
+ (HCKCommuDataConvModel *)getStepDataJsonData:(NSString *)dataString{
    if (!HCKBluetoothValidStr(dataString) || dataString.length != 28) {
        if (needCommunicationLog) {
            [HCKLogFileManager writeCommandToLocalFile:@[@"手环返回的计步数据出错"]
                                     withSourceInfo:HCKLocalDataSourceDevice];
        }
        return nil;
    }
    if (needCommunicationLog) {
        NSString *tempWriteString = [NSString stringWithFormat:@"手环返回计步数据:92%@",
                                     dataString];
        [HCKLogFileManager writeCommandToLocalFile:@[tempWriteString]
                                 withSourceInfo:HCKLocalDataSourceDevice];
    }
    HCKCommuDataConvModel *dataModel = [[HCKCommuDataConvModel alloc] init];
    dataModel.commandPostion = HCKCommuCommandPeripheralRequestStepData;
    
    NSDictionary *resultDic = @{
                                    @"SN":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(0, 2)] UTF8String],0,16)),
                                    @"year":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(2, 2)] UTF8String],0,16) + 2000),
                                    @"month":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(4, 2)] UTF8String],0,16)),
                                    @"day":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(6, 2)] UTF8String],0,16)),
                                    @"stepNumber":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(8, 8)] UTF8String],0,16)),
                                    @"activityTime":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(16, 4)] UTF8String],0,16)),
                                    @"distance":[NSString stringWithFormat:@"%.f",(float)strtoul([[dataString substringWithRange:NSMakeRange(20, 4)] UTF8String],0,16) / 10],
                                    @"calories":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(24, 4)] UTF8String],0,16)),
                                };
    if (needCommunicationLog) {
        NSString *tempWriteString1 = [NSString stringWithFormat:@"解析后的计步数据:第%ld条数据",
                                     (long)strtoul([[dataString substringWithRange:NSMakeRange(0, 2)] UTF8String],0,16)
                                     ];
        NSString *tempWriteString2 = [NSString stringWithFormat:@"计步时间:%ld-%ld-%ld",
                                      (long)((strtoul([[dataString substringWithRange:NSMakeRange(2, 2)] UTF8String],0,16) + 2000)),
                                      (long)strtoul([[dataString substringWithRange:NSMakeRange(4, 2)] UTF8String],0,16),
                                      (long)strtoul([[dataString substringWithRange:NSMakeRange(6, 2)] UTF8String],0,16)];
        NSString *tempWriteString3 = [NSString stringWithFormat:@"步数是:%ld",
                                      (long)strtoul([[dataString substringWithRange:NSMakeRange(8, 8)] UTF8String],0,16)];
        NSString *tempWriteString4 = [NSString stringWithFormat:@"运动时间:%ld",
                                      (long)strtoul([[dataString substringWithRange:NSMakeRange(16, 4)] UTF8String],0,16)];
        NSString *tempWriteString5 = [NSString stringWithFormat:@"运动距离:%f",
                                      (float)strtoul([[dataString substringWithRange:NSMakeRange(20, 4)] UTF8String],0,16) / 10];
        NSString *tempWriteString6 = [NSString stringWithFormat:@"消耗卡路里:%ld",
                                      (long)strtoul([[dataString substringWithRange:NSMakeRange(24, 4)] UTF8String],0,16)];
        [HCKLogFileManager writeCommandToLocalFile:@[tempWriteString1,tempWriteString2,tempWriteString3,tempWriteString4,tempWriteString5,tempWriteString6]
                                 withSourceInfo:HCKLocalDataSourceDevice];
    }
    dataModel.commuData = resultDic;
    
    return dataModel;
}

+ (HCKCommuDataConvModel *)getTotalOfSleepRelatedJsonData:(NSString *)dataString{
    if (!HCKBluetoothValidStr(dataString)
        || dataString.length < 2) {
        if (needCommunicationLog) {
            [HCKLogFileManager writeCommandToLocalFile:@[@"手环返回的数据出错"]
                                     withSourceInfo:HCKLocalDataSourceDevice];
        }
        return nil;
    }
    NSString *function = [dataString substringWithRange:NSMakeRange(0, 2)];
    if (!HCKBluetoothValidStr(function)) {
        if (needCommunicationLog) {
            [HCKLogFileManager writeCommandToLocalFile:@[@"手环返回的数据出错"]
                                     withSourceInfo:HCKLocalDataSourceDevice];
        }
        return nil;
    }
    if (needCommunicationLog) {
        NSString *tempWriteString = [NSString stringWithFormat:@"手环返回数据:a5%@",dataString];
        [HCKLogFileManager writeCommandToLocalFile:@[tempWriteString]
                                 withSourceInfo:HCKLocalDataSourceDevice];
    }
    HCKCommuDataConvModel *dataModel = [[HCKCommuDataConvModel alloc] init];
    NSDictionary *resultDic = nil;
    if ([function isEqualToString:@"12"]
        && dataString.length == 10) {
        //睡眠总数
        resultDic = @{
                        @"sleepIndexCount":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(2, 2)] UTF8String],0,16)),
                        @"sleepRecordCount":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(4, 2)] UTF8String],0,16)),
                        @"heartRateCount":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(6, 2)] UTF8String],0,16)),
                        @"reserved":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(8, 2)] UTF8String],0,16)),
                      };
        dataModel.commandPostion = HCKCommuCommandPeripheralRequestTotalOfSleep;
    }else if ([function isEqualToString:@"13"]
              && dataString.length == 10){
        //同步当天的数据
        resultDic = @{
                        @"sleepIndexCount":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(2, 2)] UTF8String],0,16)),
                        @"sleepRecordCount":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(4, 2)] UTF8String],0,16)),
                        @"heartRateCount":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(6, 2)] UTF8String],0,16))
                      };
        dataModel.commandPostion = HCKCommuCommandPeripheralRequestDataOfToday;
    }
    else if ([function isEqualToString:@"17"] && dataString.length == 2){
        //设置心率采集间隔成功
        dataModel.commandPostion = HCKCommuCommandPeripheralHeartRateAcquisitionInterval;
        resultDic = @{};
    }else if ([function isEqualToString:@"19"] && dataString.length == 2){
        //设置屏幕显示页面成功
        dataModel.commandPostion = HCKCommuCommandPeripheralScreenDisplay;
        resultDic = @{};
    }else if ([function isEqualToString:@"16"] && dataString.length == 2){
        //手环关闭ancs功能
        dataModel.commandPostion = HCKCommuCommandPeripheralCloseANCS;
        resultDic = @{};
    }else if ([function isEqualToString:@"18"] && dataString.length == 2){
        dataModel.commandPostion = HCKCommuCommandPeripheralHeartAck;
        resultDic = @{};
    }
    dataModel.commuData = resultDic;
    return dataModel;
}

+ (HCKCommuDataConvModel *)getSleepIndexJsonData:(NSString *)dataString{
    if (!HCKBluetoothValidStr(dataString) || dataString.length != 34) {
        if (needCommunicationLog) {
            [HCKLogFileManager writeCommandToLocalFile:@[@"手环返回的sleepIndex数据出错"]
                                     withSourceInfo:HCKLocalDataSourceDevice];
        }
        return nil;
    }
    if (needCommunicationLog) {
        NSString *tempWriteString = [NSString stringWithFormat:@"返回的睡眠index数据:93%@",
                                     dataString];
        [HCKLogFileManager writeCommandToLocalFile:@[tempWriteString]
                                 withSourceInfo:HCKLocalDataSourceDevice];
    }
    HCKCommuDataConvModel *dataModel = [[HCKCommuDataConvModel alloc] init];
    dataModel.commandPostion = HCKCommuCommandPeripheralRequestSleepIndex;
    NSDictionary *resultDic = @{
                                @"SN":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(0, 2)] UTF8String],0,16)),
                                @"startYear":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(2, 2)] UTF8String],0,16) + 2000),
                                @"startMonth":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(4, 2)] UTF8String],0,16)),
                                @"startDay":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(6, 2)] UTF8String],0,16)),
                                @"startHour":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(8, 2)] UTF8String],0,16)),
                                @"startMin":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(10, 2)] UTF8String],0,16)),
                                @"endYear":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(12, 2)] UTF8String],0,16) + 2000),
                                @"endMonth":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(14, 2)] UTF8String],0,16)),
                                @"endDay":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(16, 2)] UTF8String],0,16)),
                                @"endHour":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(18, 2)] UTF8String],0,16)),
                                @"endMin":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(20, 2)] UTF8String],0,16)),
                                @"deepSleepTime":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(22, 4)] UTF8String],0,16)),
                                @"lightSleepTime":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(26, 4)] UTF8String],0,16)),
                                @"awake":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(30, 4)] UTF8String],0,16)),
                                };
    if (needCommunicationLog) {
        NSString *tempWriteString1 = [NSString stringWithFormat:@"解析后的睡眠index数据:第%ld条index",
                                     (long)strtoul([[dataString substringWithRange:NSMakeRange(0, 2)] UTF8String],0,16)
                                     ];
        NSString *tempWriteString2 = [NSString stringWithFormat:@"开始于%ld-%ld-%ld %ld:%ld",
                                      (long)strtoul([[dataString substringWithRange:NSMakeRange(2, 2)] UTF8String],0,16) + 2000,
                                      (long)strtoul([[dataString substringWithRange:NSMakeRange(4, 2)] UTF8String],0,16),
                                      (long)strtoul([[dataString substringWithRange:NSMakeRange(6, 2)] UTF8String],0,16),
                                      (long)strtoul([[dataString substringWithRange:NSMakeRange(8, 2)] UTF8String],0,16),
                                      (long)strtoul([[dataString substringWithRange:NSMakeRange(10, 2)] UTF8String],0,16)];
        NSString *tempWriteString3 = [NSString stringWithFormat:@"结束于%ld-%ld-%ld %ld:%ld",
                                      (long)(strtoul([[dataString substringWithRange:NSMakeRange(12, 2)] UTF8String],0,16) + 2000),
                                      (long)strtoul([[dataString substringWithRange:NSMakeRange(14, 2)] UTF8String],0,16),
                                      (long)strtoul([[dataString substringWithRange:NSMakeRange(16, 2)] UTF8String],0,16),
                                      (long)strtoul([[dataString substringWithRange:NSMakeRange(18, 2)] UTF8String],0,16),
                                      (long)strtoul([[dataString substringWithRange:NSMakeRange(20, 2)] UTF8String],0,16)];
        NSString *tempWriteString4 = [NSString stringWithFormat:@"深睡时长:%ld",
                                      (long)strtoul([[dataString substringWithRange:NSMakeRange(22, 4)] UTF8String],0,16)];
        NSString *tempWriteString5 = [NSString stringWithFormat:@"浅睡时长:%ld",
                                      (long)strtoul([[dataString substringWithRange:NSMakeRange(26, 4)] UTF8String],0,16)];
        NSString *tempWriteString6 = [NSString stringWithFormat:@"清醒时长:%ld",
                                      (long)strtoul([[dataString substringWithRange:NSMakeRange(30, 4)] UTF8String],0,16)];
        
        [HCKLogFileManager writeCommandToLocalFile:@[tempWriteString1,tempWriteString2,tempWriteString3,tempWriteString4,tempWriteString5,tempWriteString6]
                                 withSourceInfo:HCKLocalDataSourceDevice];
    }
    dataModel.commuData = resultDic;
    return dataModel;
}

+ (HCKCommuDataConvModel *)getSleepRecordJsonData:(NSString *)dataString{
    if (!HCKBluetoothValidStr(dataString)) {
        if (needCommunicationLog) {
            [HCKLogFileManager writeCommandToLocalFile:@[@"手环返回的sleepRecord数据出错"]
                                     withSourceInfo:HCKLocalDataSourceDevice];
        }
        return nil;
    }
    if (needCommunicationLog) {
        NSString *tempWriteString = [NSString stringWithFormat:@"返回的睡眠index数据:94%@",
                                     dataString];
        [HCKLogFileManager writeCommandToLocalFile:@[tempWriteString]
                                 withSourceInfo:HCKLocalDataSourceDevice];
    }
    HCKCommuDataConvModel *dataModel = [[HCKCommuDataConvModel alloc] init];
    dataModel.commandPostion = HCKCommuCommandPeripheralRequestSleepRecord;
    //对应的睡眠详情长度
    NSInteger dataLen = strtoul([[dataString substringWithRange:NSMakeRange(4, 2)] UTF8String],0,16);
    //
    NSMutableArray * detailSleepInfo = [[NSMutableArray alloc] init];
    NSInteger index = 6;
    for (NSInteger i = 0; i < dataLen; i ++) {
        NSString * hexStr = [dataString substringWithRange:NSMakeRange(index, 2)];
        NSString * binaryStr = [NSString getBinaryByhex:hexStr];
        NSMutableArray * tempArr = [self getSleepDetailInfo:binaryStr];
        if ([tempArr isKindOfClass:[NSMutableArray class]] && [tempArr count] > 0) {
            [detailSleepInfo addObjectsFromArray:tempArr];
        }
        index += 2;
    }
    
    NSDictionary *resultDic = @{
                                @"SN":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(0, 2)] UTF8String],0,16)),
                                @"fragmentSN":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(2, 2)] UTF8String],0,16)),
                                @"detailSleepInfo":detailSleepInfo,
                                };
    if (needCommunicationLog) {
        NSString *tempDetailString = @"";
        for (NSString *temp in detailSleepInfo) {
            tempDetailString = [tempDetailString stringByAppendingString:[NSString stringWithFormat:@" %@",temp]];
        }
        NSString *tempWriteString1 = [NSString stringWithFormat:@"解析后的睡眠index数据:对应第%ld条睡眠index数据",
                                     (long)strtoul([[dataString substringWithRange:NSMakeRange(0, 2)] UTF8String],0,16)
                                     ];
        NSString *tempWriteString2 = [NSString stringWithFormat:@"本条数据index数据下面是第%ld条record数据",
                                      (long)strtoul([[dataString substringWithRange:NSMakeRange(2, 2)] UTF8String],0,16)];
        NSString *tempWriteString3 = [NSString stringWithFormat:@"解析后的睡眠详情:%@",tempDetailString];
        
        [HCKLogFileManager writeCommandToLocalFile:@[tempWriteString1,tempWriteString2,tempWriteString3]
                                 withSourceInfo:HCKLocalDataSourceDevice];
    }
    dataModel.commuData = resultDic;
    return dataModel;
}

+ (HCKCommuDataConvModel *)getPeripheralFirmwareVersionJsonData:(NSString *)dataString{
    if (!HCKBluetoothValidStr(dataString) || dataString.length != 6) {
        if (needCommunicationLog) {
            [HCKLogFileManager writeCommandToLocalFile:@[@"固件版本号数据出错"]
                                     withSourceInfo:HCKLocalDataSourceDevice];
        }
        return nil;
    }
    if (needCommunicationLog) {
        NSString *tempWriteString = [NSString stringWithFormat:@"固件版本号数据:90%@",dataString];
        [HCKLogFileManager writeCommandToLocalFile:@[tempWriteString]
                                 withSourceInfo:HCKLocalDataSourceDevice];
    }
    HCKCommuDataConvModel *dataModel = [[HCKCommuDataConvModel alloc] init];
    dataModel.commandPostion = HCKCommuCommandPeripheralRequestFirmwareVersion;
    NSInteger major = strtoul([[dataString substringWithRange:NSMakeRange(0, 2)] UTF8String],0,16);
    NSInteger minor = strtoul([[dataString substringWithRange:NSMakeRange(2, 2)] UTF8String],0,16);
    NSInteger revision = strtoul([[dataString substringWithRange:NSMakeRange(4, 2)] UTF8String],0,16);
    NSString *firmwareVersion = [NSString stringWithFormat:@"%@.%@.%@",
                                 bleStringFromInteger(major),
                                 bleStringFromInteger(minor),
                                 bleStringFromInteger(revision)];
    NSDictionary *resultDic = @{
                                    @"firmwareVersion":firmwareVersion
                                };
    if (needCommunicationLog) {
        NSString *tempWriteString = [NSString stringWithFormat:@"固件版本号解析后的数据:%@",firmwareVersion];
        [HCKLogFileManager writeCommandToLocalFile:@[tempWriteString]
                                 withSourceInfo:HCKLocalDataSourceDevice];
    }
    dataModel.commuData = resultDic;
    return dataModel;
}

+ (HCKCommuDataConvModel *)getPeripheralHeartRateData:(NSString *)dataString{
    if (!HCKBluetoothValidStr(dataString)
        || dataString.length != 38) {
        if (needCommunicationLog) {
            [HCKLogFileManager writeCommandToLocalFile:@[@"手环返回心率数据出错"]
                                     withSourceInfo:HCKLocalDataSourceDevice];
        }
        return nil;
    }
    if (needCommunicationLog) {
        NSString *tempWriteString = [NSString stringWithFormat:@"手环心率数据数据:a8%@",dataString];
        [HCKLogFileManager writeCommandToLocalFile:@[tempWriteString]
                                 withSourceInfo:HCKLocalDataSourceDevice];
    }
    HCKCommuDataConvModel *dataModel = [[HCKCommuDataConvModel alloc] init];
    dataModel.commandPostion = HCKCommuCommandPeripheralRequestHeartRate;
    NSArray *resultArray = @[
                                @{
                                        @"year":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(2, 2)] UTF8String],0,16) + 2000),
                                        @"month":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(4, 2)] UTF8String],0,16)),
                                        @"day":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(6, 2)] UTF8String],0,16)),
                                        @"hour":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(8, 2)] UTF8String],0,16)),
                                        @"minute":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(10, 2)] UTF8String],0,16)),
                                        @"heartRate":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(12, 2)] UTF8String],0,16))
                                    },
                                @{
                                    @"year":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(14, 2)] UTF8String],0,16) + 2000),
                                    @"month":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(16, 2)] UTF8String],0,16)),
                                    @"day":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(18, 2)] UTF8String],0,16)),
                                    @"hour":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(20, 2)] UTF8String],0,16)),
                                    @"minute":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(22, 2)] UTF8String],0,16)),
                                    @"heartRate":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(24, 2)] UTF8String],0,16))
                                    },
                                @{
                                    @"year":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(26, 2)] UTF8String],0,16) + 2000),
                                    @"month":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(28, 2)] UTF8String],0,16)),
                                    @"day":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(30, 2)] UTF8String],0,16)),
                                    @"hour":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(32, 2)] UTF8String],0,16)),
                                    @"minute":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(34, 2)] UTF8String],0,16)),
                                    @"heartRate":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(36, 2)] UTF8String],0,16))
                                    }
                             ];
    if (needCommunicationLog) {
        NSString *tempWriteString1 = [NSString stringWithFormat:@"解析后手环心率数据数据:第%ld条心率数据",
                                     (long)strtoul([[dataString substringWithRange:NSMakeRange(0, 2)] UTF8String],0,16)
                                     ];
        NSString *tempWriteString2 = [NSString stringWithFormat:@"心率时间:%ld-%ld-%ld %ld:%ld",
                                      (long)(strtoul([[dataString substringWithRange:NSMakeRange(2, 2)] UTF8String],0,16) + 2000),
                                      (long)strtoul([[dataString substringWithRange:NSMakeRange(4, 2)] UTF8String],0,16),
                                      (long)strtoul([[dataString substringWithRange:NSMakeRange(6, 2)] UTF8String],0,16),
                                      (long)strtoul([[dataString substringWithRange:NSMakeRange(8, 2)] UTF8String],0,16),
                                      (long)strtoul([[dataString substringWithRange:NSMakeRange(10, 2)] UTF8String],0,16)];
        NSString *tempWriteString3 = [NSString stringWithFormat:@"心率值:%ld",
                                      (long)strtoul([[dataString substringWithRange:NSMakeRange(12, 2)] UTF8String],0,16)];
        NSString *tempWriteString4 = [NSString stringWithFormat:@"心率时间:%ld-%ld-%ld %ld:%ld",
                                      (long)(strtoul([[dataString substringWithRange:NSMakeRange(14, 2)] UTF8String],0,16) + 2000),
                                      (long)strtoul([[dataString substringWithRange:NSMakeRange(16, 2)] UTF8String],0,16),
                                      (long)strtoul([[dataString substringWithRange:NSMakeRange(18, 2)] UTF8String],0,16),
                                      (long)strtoul([[dataString substringWithRange:NSMakeRange(20, 2)] UTF8String],0,16),
                                      (long)strtoul([[dataString substringWithRange:NSMakeRange(22, 2)] UTF8String],0,16)];
        NSString *tempWriteString5 = [NSString stringWithFormat:@"心率值:%ld",
                                      (long)strtoul([[dataString substringWithRange:NSMakeRange(24, 2)] UTF8String],0,16)];
        NSString *tempWriteString6 = [NSString stringWithFormat:@"心率时间:%ld-%ld-%ld %ld:%ld",
                                      (long)(strtoul([[dataString substringWithRange:NSMakeRange(26, 2)] UTF8String],0,16) + 2000),
                                      (long)strtoul([[dataString substringWithRange:NSMakeRange(28, 2)] UTF8String],0,16),
                                      (long)strtoul([[dataString substringWithRange:NSMakeRange(30, 2)] UTF8String],0,16),
                                      (long)strtoul([[dataString substringWithRange:NSMakeRange(32, 2)] UTF8String],0,16),
                                      (long)strtoul([[dataString substringWithRange:NSMakeRange(34, 2)] UTF8String],0,16)];
        NSString *tempWriteString7 = [NSString stringWithFormat:@"心率值:%ld",
                                      (long)strtoul([[dataString substringWithRange:NSMakeRange(36, 2)] UTF8String],0,16)];
        
        [HCKLogFileManager writeCommandToLocalFile:@[tempWriteString1,tempWriteString2,tempWriteString3,tempWriteString4,tempWriteString5,tempWriteString6,tempWriteString7]
                                 withSourceInfo:HCKLocalDataSourceDevice];
    }
    dataModel.commuData = resultArray;
    return dataModel;
}

+ (HCKCommuDataConvModel *)getPeripheralLatestData:(NSString *)dataString{
    if (!HCKBluetoothValidStr(dataString)
        || dataString.length != 4) {
        if (needCommunicationLog) {
            [HCKLogFileManager writeCommandToLocalFile:@[@"手环返回最新数据出错"]
                                     withSourceInfo:HCKLocalDataSourceDevice];
        }
        return nil;
    }
    if (needCommunicationLog) {
        NSString *tempWriteString = [NSString stringWithFormat:@"手环最新数据数据:aa%@",dataString];
        [HCKLogFileManager writeCommandToLocalFile:@[tempWriteString]
                                 withSourceInfo:HCKLocalDataSourceDevice];
    }
    NSString *fuction = [dataString substringWithRange:NSMakeRange(0, 2)];
    NSString *msgInfo = @"";
    HCKCommuDataConvModel *dataModel = [[HCKCommuDataConvModel alloc] init];
    if ([fuction isEqualToString:@"92"]) {
        //计步
        dataModel.commandPostion = HCKCommuCommandPeripheralRequestLatestStepData;
        msgInfo = @"最新计步数据";
    }else if ([fuction isEqualToString:@"93"]){
        //睡眠index
        dataModel.commandPostion = HCKCommuCommandPeripheralRequestLatestSleepIndexData;
        msgInfo = @"最新睡眠index数据";
    }else if ([fuction isEqualToString:@"94"]){
        //睡眠record
        dataModel.commandPostion = HCKCommuCommandPeripheralRequestLatestSleepRecordData;
        msgInfo = @"最新睡眠record数据";
    }else if ([fuction isEqualToString:@"a8"]){
        //心率
        dataModel.commandPostion = HCKCommuCommandPeripheralRequestLatestHeartRate;
        msgInfo = @"最新心率数据";
    }
    dataModel.commuData = @{
                                @"CNT":bleStringFromInteger(strtoul([[dataString substringWithRange:NSMakeRange(2, 2)] UTF8String],0,16))
                            };
    if (needCommunicationLog) {
        NSString *tempWriteString = [NSString stringWithFormat:@"%@%ld条",
                                     msgInfo,
                                     (long)strtoul([[dataString substringWithRange:NSMakeRange(2, 2)] UTF8String],0,16)];
        [HCKLogFileManager writeCommandToLocalFile:@[tempWriteString]
                                    withSourceInfo:HCKLocalDataSourceDevice];
    }
    return dataModel;
}

@end
