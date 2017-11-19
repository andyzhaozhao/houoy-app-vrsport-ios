//
//  HCKCommunicationTask.h
//  BluetoothDemo
//
//  Created by aa on 17/4/21.
//  Copyright © 2017年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HCKCommunicationTask : NSObject

/**
 是否是处于超时状态
 */
@property (nonatomic, assign)BOOL timeoutFlag;

/**
 创建一个数据通信任务
 
 @param target 任务超时的时候方法所在的target
 @param selector 任务超时方法
 @param timeout 超时时间
 @param queue 任务所在队列
 @param object 超时方法所用参数
 @param repeats 超时的时候是否取消定时器
 @return 数据通信任务
 */
- (HCKCommunicationTask *)initCommunicationTaskWithtarget:(id)target
                                                 selector:(SEL)selector
                                                  Timeout:(NSTimeInterval)timeout
                                                    queue:(dispatch_queue_t)queue
                                               withObject:(id)object
                                                  repeats:(BOOL)repeats;

/**
 开启定时器，用于通信的超时判断
 */
- (void)resume;

/**
 关闭定时器
 */
- (void)cancle;

@end
