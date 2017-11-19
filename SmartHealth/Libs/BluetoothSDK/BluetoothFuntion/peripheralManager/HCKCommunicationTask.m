//
//  HCKCommunicationTask.m
//  BluetoothDemo
//
//  Created by aa on 17/4/21.
//  Copyright © 2017年 HCK. All rights reserved.
//

#import "HCKCommunicationTask.h"
#import "HCKBluetoothGlobal.h"

@interface HCKCommunicationTask ()

/**
 通信时间定时器
 */
@property (nonatomic, strong)dispatch_source_t taskTimer;

/**
 定时器是否一直运行
 */
@property(nonatomic, assign) BOOL repeats;

@end

@implementation HCKCommunicationTask{
    SEL _selector;
    __weak id _target;
}

- (instancetype)init{
    @throw [NSException exceptionWithName:@"HCKCommunicationTask init error"
                                   reason:@"Use the designated initializer to init."
                                 userInfo:nil];
    return [self initCommunicationTaskWithtarget:NULL
                                        selector:NULL
                                         Timeout:1
                                           queue:dispatch_get_global_queue(0, 0)
                                      withObject:nil
                                         repeats:NO];
}


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
                                                  repeats:(BOOL)repeats{
    self.repeats = repeats;
    _selector = selector;
    _target = target;
    self.taskTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    //开始时间
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, timeout * NSEC_PER_SEC);
    //间隔时间
    uint64_t interval = timeout * NSEC_PER_SEC;
    dispatch_source_set_timer(self.taskTimer, start, interval, 0);
    HCKBluetoothWS(weakSelf);
    //设置回调
    dispatch_source_set_event_handler(self.taskTimer,
                                      ^{[weakSelf timeoutMethodWithPostion:object];});
    return self;
}

/**
 开启定时器，用于通信的超时判断
 */
- (void)resume{
    if (!self.taskTimer) {
        return;
    }
    dispatch_resume(self.taskTimer);
}

/**
 关闭定时器
 */
- (void)cancle{
    if (!self.taskTimer) {
        return;
    }
    dispatch_cancel(self.taskTimer);
}

#pragma mark - Private Method
- (void)timeoutMethodWithPostion:(id)postion{
    self.timeoutFlag = YES;
    if (!self.repeats) {
        dispatch_cancel(self.taskTimer);
    }
    if (_selector == NULL) {
        return ;
    }
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [_target performSelector:_selector
                  withObject:postion
                  withObject:@(1)];
}

- (void)dealloc{
    NSLog(@"任务销毁");
}

@end
