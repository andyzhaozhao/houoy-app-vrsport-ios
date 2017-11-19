//
//  HCKCommunicationLogFileManager.m
//  BluetoothDemo
//
//  Created by aa on 17/5/7.
//  Copyright © 2017年 HCK. All rights reserved.
//

#import "HCKCommunicationLogFileManager.h"
#import "HCKBluetoothGlobal.h"

static NSString *const localFileName = @"/HCKCommunicationData.txt";
static HCKCommunicationLogFileManager *logFileManager = nil;

@interface HCKCommunicationLogFileManager ()

/**
 写数据日期
 */
@property (nonatomic, strong)NSDateFormatter *dateFormatter;

@end

@implementation HCKCommunicationLogFileManager

+ (HCKCommunicationLogFileManager *)sharedLogFileManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!logFileManager) {
            logFileManager = [HCKCommunicationLogFileManager new];
        }
    });
    return logFileManager;
}

#pragma mark - 获取沙盒目录
/**
 获取沙盒根目录
 
 @return 沙盒根目录
 */
- (NSString *)getHomeDirectory{
    return NSHomeDirectory();
}

/**
 获取document文件目录
 
 @return document文件目录
 */
- (NSString *)getDocumentDirectory{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)lastObject];
}

/**
 获取Library文件目录
 
 @return Library文件目录
 */
- (NSString *)getLibraryDirectory{
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES)lastObject];
}

/**
 获取Caches文件目录
 
 @return Caches文件目录
 */
- (NSString *)getCachesDirectory{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES)lastObject];
}

/**
 获取tmp文件目录
 
 @return tmp文件目录
 */
- (NSString *)getTmpDirectory{
    return NSTemporaryDirectory();
}

/**
 获取用户偏好设置Preference文件目录
 
 @return Preference文件目录
 */
- (NSString *)getPreferencePanesDirectory{
    return [NSSearchPathForDirectoriesInDomains(NSPreferencePanesDirectory,NSUserDomainMask,YES)lastObject];
}

#pragma mark - Private Method

/**
 指定路径下面是否存在文件或者文件夹
 
 @param path 指定的路径
 @param isDirectory 是否是文件夹，YES:文件夹,NO:文件
 @return YES:存在，NO:不存在
 */
-(BOOL)fileExistInPath:(NSString *)path
           isDirectory:(BOOL)isDirectory{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:path
                                     isDirectory:&isDirectory];
    return existed;
}


/**
 创建文件
 
 @param path 要创建文件的路径
 @param fileName 文件名字
 @return YES:创建成功，NO:创建失败
 */
-(BOOL)createFileInPath:(NSString *)path
               fileName:(NSString *)fileName{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *newFilePath = [path stringByAppendingPathComponent:fileName];
    BOOL res = [fileManager createFileAtPath:newFilePath
                                    contents:nil
                                  attributes:nil];
    if (res) {
        //文件创建成功
        return YES;
    }else{
        //文件创建失败
        return NO;
    }
}

/**
 写文件
 
 @param string 要写入的数据
 @param path 文件路径
 */
-(void)writeStringToFile:(NSString *)string
                  inPath:(NSString *)path{
    
    NSString *datestr = [[self dateFormatter] stringFromDate:[NSDate date]];
    
    NSString *stringToWrite = [NSString stringWithFormat:@"\n%@  %@",datestr,string];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        BOOL res=[stringToWrite writeToFile:path
                                 atomically:YES
                                   encoding:NSUTF8StringEncoding
                                      error:nil];
        if (!res) {
            NSLog(@"写入数据出错");
            return;
        }
    }
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:path];
    [fileHandle seekToEndOfFile];   //将节点跳到文件的末尾
    NSData *stringData = [stringToWrite dataUsingEncoding:NSUTF8StringEncoding];
    [fileHandle writeData:stringData];
    [fileHandle closeFile];
}

/**
 读取文件
 
 @param path 文件路径
 @return 读取的数据
 */
-(NSString *)readFileInPath:(NSString *)path{
    NSString *content=[NSString stringWithContentsOfFile:path
                                                encoding:NSUTF8StringEncoding
                                                   error:nil];
    return content;
}

/**
 删除文件
 
 @param path 文件路径
 @return YES:删除成功，NO:删除失败
 */
-(BOOL)deleteFileInPath:(NSString *)path{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL res = [fileManager removeItemAtPath:path
                                       error:nil];
    if (res) {
        //文件删除成功
        return YES;
    }else{
        //文件删除失败
        return NO;
    }
}

#pragma mark - Public Method
/**
 写入命令到本地文件,本地目前只保留一周的数据
 
 @param dataList 要写入的数据，可以写入一系列的数据，数组里面必须是字符串
 @param source app-->device或者是device-->app
 */
- (void)writeCommandToLocalFile:(NSArray *)dataList
                 withSourceInfo:(HCKLocalDataSource )source{
    if (!self.openLog
        || !HCKBluetoothValidArray(dataList)) {
        return;
    }
    for (id tempString in dataList) {
        if (!HCKBluetoothValidStr(tempString)) {
            return;
        }
    }
    NSString *sourceInfo = @"app:";
    if (source == HCKLocalDataSourceDevice) {
        sourceInfo = @"device:";
    }
    NSString *path = [self getCachesDirectory];
    NSString *filePath = [path stringByAppendingString:localFileName];
    BOOL isDirectory = NO;
    BOOL exit = [self fileExistInPath:filePath
                                    isDirectory:isDirectory];
    if (!exit) {
        BOOL createResult = [self createFileInPath:path
                                                    fileName:localFileName];
        if (!createResult) {
            NSLog(@"创建文件出错");
            return;
        }
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:filePath
                                                                 error:&error];
    if (error || !HCKBluetoothValidDict(fileAttributes)) {
        return;
    }
    NSDate *createDate = fileAttributes[@"NSFileCreationDate"];
    NSString *createTimeInfo = [self.dateFormatter stringFromDate:createDate];
    
    if (!HCKBluetoothValidStr(createTimeInfo)) {
        NSLog(@"写入错误");
        return;
    }
    NSArray *timeArr = [createTimeInfo componentsSeparatedByString:@" "];
    if (!HCKBluetoothValidArray(timeArr)) {
        NSLog(@"写入错误");
        return;
    }
    NSString *createTime = timeArr[0];
    if (!HCKBluetoothValidStr(createTime)) {
        NSLog(@"写入错误");
        return;
    }
    
    NSString *datestr = [[self dateFormatter] stringFromDate:[NSDate date]];
    NSArray *dateArr = [datestr componentsSeparatedByString:@" "];
    NSString *dateInfo = dateArr[0];
    NSInteger week = [self getWeekInfoWithDateString:dateInfo];
    if (week == 1 && ![dateInfo isEqualToString:createTime]) {
        BOOL deleteResult = [self deleteFileInPath:filePath];
        if (deleteResult) {
            BOOL createResult = [self createFileInPath:path
                                                        fileName:localFileName];
            if (!createResult) {
                NSLog(@"创建文件出错");
                return;
            }
        }
    }
    //写数据部分
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    [fileHandle seekToEndOfFile];   //将节点跳到文件的末尾
    for (NSString *tempData in dataList) {
        NSString *stringToWrite = [NSString stringWithFormat:@"\n%@  %@%@",datestr,sourceInfo,tempData];
        NSLog(@"写入的数据:%@",stringToWrite);
        NSData *stringData = [stringToWrite dataUsingEncoding:NSUTF8StringEncoding];
        [fileHandle writeData:stringData];
    }
    [fileHandle closeFile];
}

/**
 根据传过来的日期，判断是周几
 
 @param dateString 时间格式必须是yyyy-MM-dd
 @return 返回对应的星期几
 */
- (NSInteger)getWeekInfoWithDateString:(NSString *)dateString{
    if (!HCKBluetoothStrValid(dateString)) {
        return 0;
    }
    NSArray * dateArr = [dateString componentsSeparatedByString:@"-"];
    
    if (!HCKBluetoothValidArray(dateArr)
        || dateArr.count != 3) {
        return 0;
    }
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:[dateArr[2] integerValue]];
    [comps setMonth:[dateArr[1] integerValue]];
    [comps setYear:[dateArr[0] integerValue]];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [gregorian dateFromComponents:comps];
    NSDateComponents *weekdayComponents = [gregorian components:NSCalendarUnitWeekday
                                                       fromDate:date];
    NSInteger weekday = [weekdayComponents weekday];
    NSInteger week = 0;
    switch (weekday) {
        case 1:
            week = 7;
            break;
        case 2:
            week = 1;
            break;
        case 3:
            week = 2;
            break;
        case 4:
            week = 3;
            break;
        case 5:
            week = 4;
            break;
        case 6:
            week = 5;
            break;
        case 7:
            week = 6;
            break;
        default: week = 0;
            break;
    }
    
    return week;
}

/**
 读取本地存储的命令数据
 
 @return 存储的命令数据
 */
- (NSData *)readCommandDataFromLocalFile{
    NSString *path = [self getCachesDirectory];
    NSString *filePath = [path stringByAppendingString:localFileName];
    NSString *fileString = [self readFileInPath:filePath];
    if (!HCKBluetoothValidStr(fileString)) {
        return nil;
    }
    NSData *fileData = [fileString dataUsingEncoding:NSUTF8StringEncoding];
    return fileData;
}

#pragma mark - setter & getter
- (NSDateFormatter *)dateFormatter{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    return _dateFormatter;
}

@end
