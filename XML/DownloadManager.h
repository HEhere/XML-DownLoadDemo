//
//  DownloadManager.h
//  XML
//
//  Created by LYD on 15/1/19.
//  Copyright (c) 2015年 lifangli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Download.h"

//下载中的block回调
typedef void(^myBlock)(long long downloadByte ,long long totalByte);

@interface DownloadManager : NSObject<downloadDelegate>
//实例化
+ (instancetype)shareDownloadManager;
//启动下载任务
- (void)starRequestTask:(NSString *)url andFileName:(NSString *)fileName andKey:(NSString *)key underway:(myBlock)underwayBlock;
//暂停下载任务
- (void)stopRequestTask:(NSString *)key;
//删除下载任务
- (void)deleteRequestTask:(NSString *)key;
//获取下载的的文件路径
- (NSString *)filePathWithURL:(NSString *)key;

@end
