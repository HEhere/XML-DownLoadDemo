//
//  DownloadManager.m
//  XML
//
//  Created by LYD on 15/1/19.
//  Copyright (c) 2015年 lifangli. All rights reserved.
//

#import "DownloadManager.h"

@implementation DownloadManager{
    //下载任务队列
    NSMutableDictionary *_requestTaskDict;
    //下载任务的临时文件路径
    NSMutableDictionary *_taskTempPathDict;
}

//单例类实例化
+ (instancetype)shareDownloadManager{
    static DownloadManager *downloadManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        downloadManager = [[DownloadManager alloc] init];
    });
    return downloadManager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        //实例化工作
        _requestTaskDict = [[NSMutableDictionary alloc] init];
        _taskTempPathDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

//添加下载任务
- (void)starRequestTask:(NSString *)url andFileName:(NSString *)fileName andKey:(NSString *)key underway:(myBlock)underwayBlock {
    //判断任务是否已经存在
    if ([_requestTaskDict objectForKey:url]) {//存在
        NSLog(@"任务已经在进行");
        return;
        
    }else{//不存在
        //实例化任务
        Download *dl = [[Download alloc] init];
        dl.taskKey = key;
        dl.delegate = self;
        [dl starRequestTask:url andFile:fileName andUnderway:underwayBlock];
        [_requestTaskDict setObject:dl forKey:key];
    }
}

//暂停下载任务
- (void)stopRequestTask:(NSString *)key{
    Download *dl = [_requestTaskDict objectForKey:key];
    if (dl) {
        [dl stopRequestTask];
        [_requestTaskDict removeObjectForKey:key];
    }else{
        NSLog(@"任务不存在!");
    }
}

//删除下载任务
- (void)deleteRequestTask:(NSString *)key{
    Download *dl = [_requestTaskDict objectForKey:key];
    if (dl) {
        //[dl deleteRequestTask];
        [dl stopRequestTask];
        [_requestTaskDict removeObjectForKey:key];
        
        //删除临时文件
        NSFileManager *FM = [NSFileManager defaultManager];
        NSString *path = [_taskTempPathDict objectForKey:key];
        if ([FM removeItemAtPath:path error:nil]) {
            NSLog(@"--------------------任务删除成功-------------------");
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }else{
            NSLog(@"--------------------任务删除失败-------------------");
        }
        
    }else{
        NSLog(@"任务不存在!");
    }
}

//获取下载的的文件路径
- (NSString *)filePathWithURL:(NSString *)key{
    Download *dl = [_requestTaskDict objectForKey:key];
    if (dl) {
        return [dl filePath];
    }else{
        return nil;
    }
}

#pragma mark ---------------------------- downLoad的协议方法 --------------------------------
//下载开始
- (void)downloadStar:(Download *)download{
    //存储任务的临时文件路径
    NSString *key = download.taskKey;
    if (![_taskTempPathDict objectForKey:key]) {
        NSString *tempPath = [download fileTempPath];
        [_taskTempPathDict setObject:tempPath forKey:key];
    }
}

//任务进行中
- (void)downloadProgresing:(Download *)download{
    
}

//下载完成
- (void)downloadDidFinish:(Download *)download andIsSuccess:(BOOL)success{
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (success) {//下载成功
        [dict setObject:@"1" forKey:@"success"];
    }else{//下载失败
        [dict setObject:@"0" forKey:@"success"];
    }
    
    //压缩文件路径
    NSString *filePath = [download filePath];
    if (filePath) {
        [dict setObject:filePath forKey:@"filePath"];
    }
    
    //临时文件路径
    NSString *fileTempPath = [download fileTempPath];
    if (fileTempPath) {
        [dict setObject:fileTempPath forKey:@"fileTempPath"];
    }
    
    //下载任务的key --- mapId
    NSString *key = download.taskKey;
    if (key) {
        [dict setObject:key forKey:@"taskKey"];
    }
    
    //任务完成，移除该任务
    [_requestTaskDict removeObjectForKey:download.taskKey];
    
    //通知任务发起类，下载任务已经完成
    [[NSNotificationCenter defaultCenter] postNotificationName:download.taskKey object:nil userInfo:dict];
}

- (void)dealloc{
    NSLog(@"被销毁");
}

@end
