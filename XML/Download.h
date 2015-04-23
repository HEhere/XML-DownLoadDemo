//
//  Download.h
//  XML
//
//  Created by LYD on 15/1/19.
//  Copyright (c) 2015年 lifangli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class Download;

@protocol downloadDelegate <NSObject>
//任务下载开始
- (void)downloadStar:(Download *)download;
//任务进行中
- (void)downloadProgresing:(Download *)download;
//任务下载完成
- (void)downloadDidFinish:(Download *)download andIsSuccess:(BOOL)success;

@end

@interface Download : NSObject<NSURLConnectionDataDelegate,NSURLConnectionDelegate>
//代理
@property(nonatomic,weak)__weak id<downloadDelegate>delegate;
//存取数据所用的key
@property(nonatomic,strong)NSString *taskKey;
//开始下载 --- 会进行判断是否有缓存文件
- (void)starRequestTask:(NSString *)urlStr andFile:(NSString *)fileName andUnderway:(void (^)(long long downloadByte, long long totalByte))underwayBlock;
//暂停下载任务
- (void)stopRequestTask;
//删除任务
- (void)deleteRequestTask;
//返回临时文件路径
- (NSString *)fileTempPath;
//返回文件压缩路径
- (NSString *)filePath;

@end
