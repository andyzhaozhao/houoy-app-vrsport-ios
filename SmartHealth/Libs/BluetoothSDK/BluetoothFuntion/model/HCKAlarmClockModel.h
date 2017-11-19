//
//  HCKAlarmClockModel.h
//  BluetoothDemo
//
//  Created by aa on 17/4/24.
//  Copyright © 2017年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 闹钟类型

 - alarmClockNormal: 普通闹钟
 */
typedef NS_ENUM(NSInteger, alarmClockType) {
    alarmClockNormal,           //普通
    alarmClockMedicine,         //吃药
    alarmClockDrink,            //喝水
    alarmClockSleep,            //睡眠
    alarmClockExcise,           //锻炼
    alarmClockSport,            //运动
};

@interface HCKAlarmClockModel : NSObject

/**
 闹钟类型
 */
@property (nonatomic, assign)alarmClockType clockType;

/**
 闹钟开启和关闭的日期(周一至周日)数组，依次为周一至周日，相应位置@"01"代表开启，@"00"代表关闭，@[@"00",@"00",@"00",@"00",@"00",@"00",@"00"]代表周一至周日全部关闭，@[@"01",@"01",@"01",@"01",@"01",@"01",@"01"]代表周一至周日全部开启，
 */
@property (nonatomic, strong)NSArray *clockSettings;

/**
 闹钟时间信息，时间格式必须是HH:mm
 */
@property (nonatomic, copy)NSString *clockTime;

@end
