//
//  HCKCommunicationLogFileManager.h
//  BluetoothDemo
//
//  Created by aa on 17/5/7.
//  Copyright © 2017年 HCK. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HCKLocalDataSource) {
    HCKLocalDataSourceAPP,          //来自于app-->device的数据
    HCKLocalDataSourceDevice,       //来自于device-->app的数据，
};

@interface HCKCommunicationLogFileManager : NSObject

#pragma mark - init method
+ (HCKCommunicationLogFileManager *)sharedLogFileManager;

/**
 数据通信过程是否需要日志，YES需要，NO不需要
 */
@property (nonatomic, assign)BOOL openLog;

#pragma mark - 获取沙盒目录
/**
 获取沙盒根目录
 
 @return 沙盒根目录
 */
- (NSString *)getHomeDirectory;

/**
 获取document文件目录
 
 @return document文件目录
 */
- (NSString *)getDocumentDirectory;

/**
 获取Library文件目录
 
 @return Library文件目录
 */
- (NSString *)getLibraryDirectory;

/**
 获取tmp文件目录
 
 @return tmp文件目录
 */
- (NSString *)getTmpDirectory;

/**
 获取用户偏好设置Preference文件目录
 
 @return Preference文件目录
 */
- (NSString *)getPreferencePanesDirectory;

#pragma mark -
/**
 写入命令到本地文件,本地目前只保留一周的数据
 
 @param dataList 要写入的数据，可以写入一系列的数据，数组里面必须是字符串
 @param source app-->device或者是device-->app
 */
- (void)writeCommandToLocalFile:(NSArray *)dataList
                 withSourceInfo:(HCKLocalDataSource )source;

/**
 读取本地存储的命令数据
 
 @return 存储的命令数据
 */
- (NSData *)readCommandDataFromLocalFile;

@end
